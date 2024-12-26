{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xdg.autoStart;
  inherit (lib) hm types;
in {
  options.xdg.autoStart = {
    packages = lib.mkOption {
      description = ''
        List of packages which should be autostarted.

        This module tries to select the package’s default desktop file,
        which is either described by its .desktopItem attribute
        or by its first entry of its .desktopItems attribute.

        Users who want to specifically select a certain desktop file
        or who want to write their own
        can make use of the {option}`xdg.autoStart.desktopItems` option.
      '';

      type = types.listOf types.package;
      default = [];
      example = lib.literalExpression ''
        with pkgs; [
          pkgs.trilium-desktop
        ]
      '';
    };

    desktopItems = lib.mkOption {
      description = ''
        List of desktop files which should be autostarted.

        Users should prefer to use {option}`xdg.autoStart.packages`
        and only use this option in case
        they want to specifically
        select a package’s desktop item
        or want to create their own desktop item.

        Be warned, this may shadow entries of {option}`xdg.autoStart.packages`.
      '';

      type = types.attrsOf types.unspecified; # TODO replace unspecified
      default = {};
      # TODO improve example, take one where it would make sense to use this option
      example = lib.literalExpression ''
        {
          discord = pkgs.discord.desktopItem
          firefox-custom = makeDesktopItem {
            exec = "firefox -P custom";
          };
        }
      '';
    };
  };

  config = let
    # helpers
    retrieveDesktopItem = pkg: let
      desktopItems = lib.toList pkg.desktopItems or [];
    in
      if desktopItems == []
      then abort "package '${pkg.pname or "unknown"}' is missing a desktop file"
      else builtins.head desktopItems;

    emulateDesktopItem = pkg:
      lib.nameValuePair pkg.pname (retrieveDesktopItem pkg);
    embedDesktopItem = name: desktopItem:
      lib.nameValuePair "autostart/${name}.desktop" {
        source = "${desktopItem}/share/applications/${desktopItem.name}";
      };

    # parse opts
    desktopItemsPackages = builtins.listToAttrs (map emulateDesktopItem cfg.packages);
    desktopItems = desktopItemsPackages // cfg.desktopItems;
  in {
    assertions = [
      (hm.assertions.assertPlatform "xdg.autoStart" pkgs lib.platforms.linux)
    ];

    xdg.configFile = lib.attrsets.mapAttrs' embedDesktopItem desktopItems;
  };
}
