{
  description = "xdg.autostart Home-Manager module";

  inputs = {

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      _class = "flake";

      flake = {

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
