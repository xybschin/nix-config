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
