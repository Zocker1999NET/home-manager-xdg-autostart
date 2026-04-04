# integrates nix-flake-tests with flake-parts
{
  config,
  flake-parts-lib,
  inputs,
  lib,
  ...
}:
let
  inherit (builtins)
    all
    attrNames
    mapAttrs
    substring
    ;
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (inputs) nix-flake-tests;
  inherit (lib) types;
  inherit (lib.asserts) assertMsg;
  inherit (lib.options) literalExpression mkOption;

  validTestName = name: substring 0 4 name == "test";

  test = types.submodule {
    freeformType = with types; attrsOf raw;
    options = {
      expected = mkOption {
        description = "The value which is the tested expression should return.";
        type = types.raw;
        example = 6;
      };
      expr = mkOption {
        description = "The expression to be tested";
        type = types.raw;
        example = literalExpression ''
          builtins.foldl' (acc: elem: acc + elem) 0 [ 1 2 3 ]
        '';
      };
    };
  };

  testSet = types.submodule (
    { config, ... }:
    {
      options = {
        tests = mkOption {
          description = "The tests which should be executed";
          type = types.attrsOf test;
          example = literalExpression ''
            {
              testBuiltinFoldl = {
                expected = 6;
                expr = builtins.foldl' (acc: elem: acc + elem) 0 [ 1 2 3 ];
              };
            }
          '';
        };
      };
    }
  );

  # generalized stuff

  translateSet =
    pkgs: testSet:
    assert assertMsg (all validTestName (
      attrNames testSet.tests
    )) ''only tests with prefix "test" are actually evaluated by lib.debug.runTests'';
    nix-flake-tests.lib.check ({
      inherit pkgs;
      inherit (testSet) tests;
    });
  translateSetAttr = pkgs: mapAttrs (_: translateSet pkgs);

  generalizedOptions = {
    testSets = mkOption {
      description = ''
        Define sets of tests as accepted by `lib.debug.runTests`.

        Each set is integrated into its own checks attribute for all systems.
      '';
      type = types.attrsOf testSet;
      default = { };
    };
  };

in
{

  _class = "flake";

  options = {

    nix-flake-tests = generalizedOptions;

    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      {
        options.nix-flake-tests = generalizedOptions;

        config = {
          checks = translateSetAttr pkgs config.nix-flake-tests.testSets;
        };
      }
    );

  };

  config = {

    perSystem =
      { pkgs, ... }:
      {
        checks = translateSetAttr pkgs config.nix-flake-tests.testSets;
      };

  };

}
