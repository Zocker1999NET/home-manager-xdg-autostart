{
  config,
  lib,
  ...
}:
let
  cfg = config.xdg.autostart;
  inherit (builtins) concatLists filter head;
  inherit (lib) types;
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
        can make use of the {option}`xdg.autostart.entries` option.
      '';

      type = types.listOf types.package;
      default = [ ];
      example = literalExpression ''
        with pkgs; [
          pkgs.trilium-desktop
        ]
      '';
    };

  };

  config =
    let
      retrieveDesktopItem =
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
          (deskItem: "${deskItem}/share/applications/${deskItem.name}")
        ];
    in
    {
      xdg.autostart.entries = map retrieveDesktopItem cfg.packages;
    };

}
