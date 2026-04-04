{
  description = "xdg.autostart Home-Manager module";

  inputs = {

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # for testing
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests/main";

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      _class = "flake";

      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.home-manager.flakeModules.default
        ./tests
      ];

      flake = {

        # export by-product
        flakeModules = {
          default = { }; # nix flake check wants this
          nix-flake-tests.imports = [ ./tests/nix-flake-tests.nix ];
        };

        homeManagerModules = rec {
          default = xdg-autostart;
          xdg-autostart.imports = [ ./. ];
        };

      };

      systems = [
        "x86_64-linux"
      ];

    };
}
