{
  ...
}:
let
  scripts = ./scripts;
  hyprlandUser = ./hyprland-user;
in
{
  imports = [
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/desktop/wm/hyprland
    ../../../modules/home-manager/waybar-audio-control.nix
  ];

  xdg.configFile."hypr/binds.user.lua".source = "${hyprlandUser}/binds.user.lua";
  xdg.configFile."hypr/rules.user.lua".source = "${hyprlandUser}/rules.user.lua";
  xdg.configFile."hypr/autostart.user.lua".source = "${hyprlandUser}/autostart.user.lua";
  xdg.configFile."hypr/settings.user.lua".source = "${hyprlandUser}/settings.user.lua";
  xdg.configFile."hypr/scripts/rofi-monitor-menu".source = "${scripts}/rofi-monitor-menu";
  xdg.configFile."hypr/scripts/monitor-config".source = "${scripts}/monitor-config";
  xdg.configFile."hypr/scripts/auto-hide-wine-trays".source = "${scripts}/auto-hide-wine-trays";

  # Cap VRAM reported to DXVK games, leaving ~512 MiB for compositor and other GPU apps.
  # RTX 2070 Super has 8192 MiB total; 7680 = 7.5 GB.
  home.file.".config/dxvk.conf".text = ''
    dxgi.maxDeviceMemory = 7680
  '';
}
