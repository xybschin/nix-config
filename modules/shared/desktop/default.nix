{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    feh
  ];

  services.udiskie.enable = true;

  dconf.settings = {
    "org/gnome/desktop/media-handling" = {
      automount = true;
      automount-open = false;
    };
  };

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
