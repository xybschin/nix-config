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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = [ "feh.desktop" ];
      "image/jpeg" = [ "feh.desktop" ];
      "image/gif" = [ "feh.desktop" ];
      "image/webp" = [ "feh.desktop" ];
      "image/bmp" = [ "feh.desktop" ];
      "image/tiff" = [ "feh.desktop" ];
      "image/x-portable-anymap" = [ "feh.desktop" ];
    };
  };

  imports = [
    ./ghostty.nix
    ./waybar.nix
    ./font.nix
    ./cursor.nix
    ./zen-browser.nix
    ./rofi
    ./wayland-env.nix
    ./hyprpaper
  ];
}
