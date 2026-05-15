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
    ./hyprlock.nix
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

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
  };

  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink hyprDir;

  services.hyprpolkitagent.enable = true;
}
