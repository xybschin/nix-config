{
  lib,
  ...
}:
let
  scripts = ./scripts;
in
{
  imports = [
    ../../../modules/home-manager/desktop/wm/hyprland
  ];

  services.hyprpaper.wallpaper = [
    {
      monitor = "DP-1";
      path = "/home/bjarne/wallpapers/left.jpg";
    }
    {
      monitor = "HDMI-A-1";
      path = "/home/bjarne/wallpapers/right.jpg";
    }
    {
      monitor = "Virtual-1";
      path = "/home/bjarne/wallpapers/left.jpg";
    }
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [ ];

    exec = [
      "${scripts}/monitor-config"
    ];

    exec-once = [
      "sleep 3; uwsm-app -- 1password --silent"
      "${scripts}/auto-hide-wine-trays"
      "${scripts}/monitor-config"
    ];

    bind = [
      "$mod SHIFT, d, exec, ${scripts}/rofi-monitor-menu"
    ];
  };
}
