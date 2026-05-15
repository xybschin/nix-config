{
  config,
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

  xdg.configFile."hypr/binds.nixvidia.lua".source = ./binds.nixvidia.lua;
  xdg.configFile."hypr/scripts/rofi-monitor-menu".source = "${scripts}/rofi-monitor-menu";
  xdg.configFile."hypr/scripts/monitor-config".source = "${scripts}/monitor-config";

  # Cap VRAM reported to DXVK games, leaving ~512 MiB for compositor and other GPU apps.
  # RTX 2070 Super has 8192 MiB total; 7680 = 7.5 GB.
  home.file.".config/dxvk.conf".text = ''
    dxgi.maxDeviceMemory = 7680
  '';
}
