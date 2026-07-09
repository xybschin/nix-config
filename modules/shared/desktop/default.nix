{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    feh
  ];

  imports = [
    ../stylix
    ./waybar
    ./font.nix
    ./zen-browser.nix
    ./rofi
    ./wayland-env.nix
    ./hyprpaper
  ];
}
