{ config, configRoot, ... }:
let
  wallpapersDir = "${configRoot}/config/shared/_desktop/hyprpaper/wallpapers/single";
in
{
  services.hyprpaper.enable = true;

  home.file.wallpapers.source = config.lib.file.mkOutOfStoreSymlink "${wallpapersDir}";
}
