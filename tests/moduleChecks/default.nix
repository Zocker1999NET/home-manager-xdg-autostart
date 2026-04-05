{
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (builtins)
    all
    attrValues
    foldl'
    isList
    length
    mapAttrs
    match
    ;
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.modules) setDefaultModuleLocation;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) flip;

  # same signature as all
  countMatches = cond: foldl' (acc: val: acc + (if cond val then 1 else 0)) 0;

  matchesDesktopItem =
    path: (match "^/nix/store/[^/]+/share/applications/[^/]+.desktop" path) != null;

  buildExpectedPkgAttr =
    {
      singular ? singularIsList,
      singularIsList ? false,
      plural ? pluralIsList,
      pluralIsList ? false,
    }:
    {
      inherit
        singular
        singularIsList
        plural
        pluralIsList
        ;
    };
  checkPkgAttr = package: {
    singular = package ? desktopItem;
    singularIsList = isList (package.desktopItem or null);
    plural = package ? desktopItems;
    pluralIsList = isList (package.desktopItems or null);
  };
in
{

  _class = "flake";

  perSystem =
    { pkgs, ... }:
    let

      baseModule =
        { config, ... }:
        {
          imports = [
            self.homeManagerModules.xdg-autostart
          ];
          options.result = mkOption {
            description = "expr for the test";
            type = types.raw;
            readOnly = true;
            default = config.xdg.autostart.entries;
          };
          config = {
            home = {
              homeDirectory = "/home/${config.home.username}";
              stateVersion = config.home.version.release;
              username = "nonimportant";
            };
          };
        };

      testConfiguration =
        module:
        (inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            baseModule
            (setDefaultModuleLocation ./default.nix module)
          ];
          inherit pkgs;
        }).config.result;

      testPackages = packages: testConfiguration { xdg.autostart.packages = packages; };

      testForAll =
        conditions: packages:
        countMatches (value: all (cond: cond value) conditions) (testPackages packages);

      testAllEntries = testForAll [
        matchesDesktopItem
      ];

      buildTestAllEntries = packages: {
        expected = length packages;
        expr = testAllEntries packages;
      };

      # selectedExamples block
      selectedExamples = with pkgs; {
        singular_item = clonehero;
        plural_item = equibop;
        plural_list = trilium-desktop;
        both_item_list = fastqc;
      };
      requiredPkgAttr = mapAttrs (_: buildExpectedPkgAttr) {
        singular_item.singular = true;
        plural_item.plural = true;
        plural_list.pluralIsList = true;
        both_item_list = {
          singular = true;
          pluralIsList = true;
        };
      };
      verifyExamples = flip mapAttrs' selectedExamples (
        name: pkg:
        nameValuePair "test_${name}" {
          expected = requiredPkgAttr.${name};
          expr = checkPkgAttr pkg;
        }
      );

    in
    {
      nix-flake-tests.testSets = {

        # strictly not testing my module, but the assumptions for the other tests
        prerequisites.tests = {
          testBaseResultEmpty = {
            expected = [ ];
            expr = testConfiguration { };
          };
          # selectedExamples
        }
        // verifyExamples;

        moduleChecks.tests = {
          testOptionExample = buildTestAllEntries [ pkgs.trilium-desktop ];
          testSelectedExamples = buildTestAllEntries (attrValues selectedExamples);
        };

      };
    };

}
