{ ... }:
{
  # Only runs the daemon; hyprpaper.conf is managed by hand, not by Nix
  # (home-manager only writes it when services.hyprpaper.settings is set).
  services.hyprpaper.enable = true;

  home.file.wallpapers.source = ./wallpapers;
}
