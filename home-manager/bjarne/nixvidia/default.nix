{
  ...
}:
let
  scripts = ./scripts;
in
{
  imports = [
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/desktop/wm/hyprland
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [ ];

    exec = [
      "${scripts}/monitor-config"
    ];

    exec-once = [
      "xembedsniproxy"
      "sleep 3; uwsm-app -- 1password --silent"
      "${scripts}/auto-hide-wine-trays"
      "${scripts}/monitor-config"
    ];

    bind = [
      "$mod SHIFT, d, exec, ${scripts}/rofi-monitor-menu"
    ];

    windowrule = [
      "match:title = 'World of Warcraft' border_size 0 float off"
      "match:title = 'Diablo IV' border_size 0 float off"
      "match:xwayland true, match:title ^$, match:class ^$, match:initial_class ^$, match:initial_title ^$, opacity 0.0, float true, no_blur on"
    ];
  };

  # Cap VRAM reported to DXVK games, leaving ~512 MiB for compositor and other GPU apps.
  # RTX 2070 Super has 8192 MiB total; 7680 = 7.5 GB.
  home.file.".config/dxvk.conf".text = ''
    dxgi.maxDeviceMemory = 7680
  '';
}
