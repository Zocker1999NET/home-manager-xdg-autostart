{
  description = "xdg.autostart Home-Manager module";

  outputs =
    { self }:
    {
      homeManagerModules = rec {
        default = xdg-autostart;
        xdg-autostart.imports = [ ./. ];
      };
    };
}
