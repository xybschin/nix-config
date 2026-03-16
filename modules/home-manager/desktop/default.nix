{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./waybar.nix
    ./font.nix
    ./cursor.nix
    ./zen-browser.nix
    ./rofi
    ./wm/hyprland
  ];

}
