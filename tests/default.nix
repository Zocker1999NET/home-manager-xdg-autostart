{ ... }:
{

  _class = "flake";

  imports = [
    ./moduleChecks
    ./nix-flake-tests
  ];

}
