{
  config,
  configRoot,
  ...
}:

let
  rofiConfigDir = "${configRoot}/config/shared/_desktop/rofi/config";
in
{
  xdg.dataFile."rofi/themes/koda-launcher.rasi".source =
    config.lib.file.mkOutOfStoreSymlink "${rofiConfigDir}/koda-launcher.rasi";
}
