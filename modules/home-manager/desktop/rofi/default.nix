{ pkgs, ... }:
{
  home.packages = [ pkgs.rofi ];
  xdg.configFile."rofi/config.rasi".source = ./config.rasi;
  xdg.configFile."rofi/scripts".source = ./scripts;
}
