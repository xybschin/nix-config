{ pkgs, ... }:

let
  mkUser = import ../../../lib/mkuser.nix;
in
mkUser {
  inherit pkgs;
  name = "bjarne";
  extraGroups = [
    "networkmanager"
    "openrazer"
  ];
}
