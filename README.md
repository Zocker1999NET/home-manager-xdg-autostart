# Home-Manager XDG Autostart Module

This module for Home-Manager
allows to easily define a list of applications
which should automatically be started by your DE when you login.

This is achieved by adhering to the XDG Autostart specification.
This means your DE needs to be capable of parsing desktop files
stored in `${XDG_CONFIG_HOME:~/.config}/autostart`.

This project is inspired by the discussion in [this issue](https://github.com/nix-community/home-manager/issues/3447#issuecomment-2213029759).


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
