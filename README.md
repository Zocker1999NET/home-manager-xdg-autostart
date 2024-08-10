# Home-Manager XDG Autostart Module

This module for Home-Manager
allows to easily define a list of applications
which should automatically be started by your DE when you login.

This is achieved by adhering to the XDG Autostart specification.
This means your DE needs to be capable of parsing desktop files
stored in `${XDG_CONFIG_HOME:~/.config}/autostart`.

This project is inspired by the discussion in [this issue](https://github.com/nix-community/home-manager/issues/3447#issuecomment-2213029759).


# Usage

This repository is prepared for flake as for non-flake configurations.
To avoid duplicated documentation,
you can learn
how to import external modules into your setup
either from [the NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_modules#Using_external_NixOS_modules)
or from [this repository’s great README](https://github.com/musnix/musnix#basic-usage).

After importing this module,
you can use these options in your home configuration:

```nix
{ config, pkgs, ... }: {
  xdg.autoStart = {
    # a list of packages
    # this is not guranteed to work with most packages (read Design Choices below)
    packages = with pkgs; [
      trilium-desktop
    ];
    # list of custom desktop files
  }
}
```

## Supported Desktop Environments

I assume most of the popular desktop environments are adhering to the XDG Autostart specification,
so applications configured by this module
should autostart on login as expected.

This module was successfully tested "out of the box" in following DEs (installed via):

- KDE Plasma 6
  - with NixOS config `services.desktopManager.plasma6.enable = true` (on NixOS 24.05)

You can append your DE to the list if this module works for you "out of the box" as well.


# Development Status

I made this module for my personal use
and to try out publishing my first flake-based module on my own.

I intent to upstream this module to home-manager
if it can be considered stable & functional enough.


# Design Choices

In case of parsing a given list of packages,
this module relies on packages having a `.desktopItem` / `.desktopItems` attribute.
I have decided to not implement
any advanced techniques for automatically finding desktop files
(e.g. [this](https://github.com/nix-community/home-manager/issues/3447#issuecomment-2213029759))
because:

- because such mechanisms are prone to error
- because I’m still new to the Nix language
- because, in my opinion, package definitions should expose such common attributes, if applicable,
  to ease the implementation of advanced features.

But, still, feel free to argument with me about that
if you think such advanced techniques are useful despite their implementation complexity.

# Contribution

Please feel free to contribute using PRs.
Also feel free to correct my Nix beginner’s mistakes.


# License

This code is licensed under MIT.
