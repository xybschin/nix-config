{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/home/coding-agents
    ../../../modules/shared/desktop
    ../../../modules/shared/desktop/wm/hyprland
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
    python3
    nodejs
    bun
  ];

  home.sessionPath = [ "$HOME/.bun/bin" ];

  home.sessionVariables = {
    NODE_USE_SYSTEM_CA = "1";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "Virtual-1,1920x1080@60,0x0,1"
  ];
}
