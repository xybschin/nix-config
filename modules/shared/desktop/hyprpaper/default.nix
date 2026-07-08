{ ... }:
{
  # Stylix sets wallpaper path via stylix.image, but we need to enable hyprpaper
  # since stylix's hyprland target is disabled (Lua config)
  services.hyprpaper.enable = true;

  home.file.wallpapers.source = ./wallpapers;
}
