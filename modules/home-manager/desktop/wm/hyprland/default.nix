{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  hyprDir = "${configRoot}/modules/home-manager/desktop/wm/hyprland/config";
in
{
  imports = [
    ../../hyprpaper
  ];

  home.packages = with pkgs; [
    socat
    jq
    hyprcursor
    hyprshot
    hyprshutdown
    hyprpicker
  ];

  # Don't use home-manager's hyprland module config generation
  # We provide our own Lua config files instead
  # Hyprland is launched via systemd service from NixOS system config

  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprDir}/hyprland.lua";
  xdg.configFile."hypr/env.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/env.lua";
  xdg.configFile."hypr/settings.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${hyprDir}/settings.lua";
  xdg.configFile."hypr/binds.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/binds.lua";
  xdg.configFile."hypr/rules.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/rules.lua";

  services.hyprpolkitagent.enable = true;
}
