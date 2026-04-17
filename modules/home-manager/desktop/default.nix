{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    feh
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  imports = [
    ./ghostty.nix
    ./waybar
    ./font.nix
    ./cursor.nix
    ./zen-browser.nix
    ./rofi
    ./wayland-env.nix
    ./hyprpaper
  ];
}
