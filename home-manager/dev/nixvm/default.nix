{ ... }:
{
  imports = [
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/desktop/wm/hyprland
  ];

  wayland.windowManager.hyprland.settings.monitor = [
    "Virtual-1,1920x1080@60,0x0,1"
  ];
}
