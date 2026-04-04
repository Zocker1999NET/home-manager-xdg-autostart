{
  description = "xdg.autostart Home-Manager module";

  outputs =
    { self }:
    {
      homeManagerModules = {
        xdg-autostart = import ./.;
      };
    };
}
