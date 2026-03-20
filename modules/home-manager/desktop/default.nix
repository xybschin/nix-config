{ pkgs, ... }:
{
  home.packages = [ pkgs.nautilus ];

  imports = [
    ./ghostty.nix
    ./waybar.nix
    ./font.nix
    ./cursor.nix
    ./zen-browser.nix
    ./rofi
  ];
}
