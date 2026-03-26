{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    feh
  ];

  imports = [
    ./ghostty.nix
    ./waybar.nix
    ./font.nix
    ./cursor.nix
    ./zen-browser.nix
    ./rofi
  ];
}
