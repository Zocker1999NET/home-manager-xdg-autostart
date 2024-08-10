{
  description = "xdg.autoStart Home-Manager module";

  outputs = { self }: {
    homeManagerModules = {
      xdg-autostart = import ./.;
    };
  };
}
