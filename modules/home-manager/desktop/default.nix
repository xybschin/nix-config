{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./waybar.nix
    ./font.nix
    ./rofi
    ./wm/hyprland
  ];

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

}
