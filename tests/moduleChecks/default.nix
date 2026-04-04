{
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.modules) setDefaultModuleLocation;
  inherit (lib.options) mkOption;
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

    in
    {
      nix-flake-tests.testSets = {

        # strictly not testing my module, but the assumptions for the other tests
        prerequisites.tests = {
          testBaseResultEmpty = {
            expected = [ ];
            expr = testConfiguration { };
          };
        };

      };
    };

}
