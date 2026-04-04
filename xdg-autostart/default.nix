{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.xdg.autostart;
  inherit (builtins) concatLists filter head;
  inherit (lib) hm types;
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.lists) singleton toList;
  inherit (lib.modules) literalExpression;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) pipe;
in
{

  options.xdg.autostart = {

    packages = mkOption {
      description = ''
        List of packages which should be autostarted.

        This module tries to select the package’s default desktop file,
        which is either described by its .desktopItem attribute
        or by its first entry of its .desktopItems attribute.

        Users who want to specifically select a certain desktop file
        or who want to write their own
        can make use of the {option}`xdg.autostart.desktopItems` option.
      '';

      type = types.listOf types.package;
      default = [ ];
      example = literalExpression ''
        with pkgs; [
          pkgs.trilium-desktop
        ]
      '';
    };

    desktopItems = mkOption {
      description = ''
        List of desktop files which should be autostarted.

        Users should prefer to use {option}`xdg.autostart.packages`
        and only use this option in case
        they want to specifically
        select a package’s desktop item
        or want to create their own desktop item.

        Be warned, this may shadow entries of {option}`xdg.autostart.packages`.
      '';

      type = types.attrsOf (types.unspecified); # TODO replace unspecified
      default = { };
      # TODO improve example, take one where it would make sense to use this option
      example = literalExpression ''
        {
          discord = pkgs.discord.desktopItem
          firefox-custom = makeDesktopItem {
            exec = "firefox -P custom";
          };
        }
      '';
    };

  };

  config =
    let
      # helpers
      retrieveDesktopItem = (
        pkg:
        let
          items = [
            (pkg.desktopItems or null)
            (pkg.desktopItem or null)
            # abort must be packed inside list so it may only be triggered after concatLists
            (singleton (abort "package '${pkg.pname}' is missing a desktop file"))
          ];
        in
        pipe items [
          (filter (x: x != null))
          (map toList)
          concatLists
          head
        ]
      );
      emulateDesktopItem = (pkg: nameValuePair pkg.pname (retrieveDesktopItem pkg));
      embedDesktopItem = (
        name: deskItem:
        nameValuePair "autostart/${name}.desktop" {
          source = "${deskItem}/share/applications/${deskItem.name}";
        }
      );
      # parse opts
      desktopItemsPackages = builtins.listToAttrs (map emulateDesktopItem cfg.packages);
      desktopItems = desktopItemsPackages // cfg.desktopItems;
    in
    {
      assertions = [
        (hm.assertions.assertPlatform "xdg.autostart" pkgs lib.platforms.linux)
      ];

      xdg.configFile = mapAttrs' embedDesktopItem desktopItems;
    };

}
