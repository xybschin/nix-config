{
  pkgs,
  ...
}:

let
  scripts = ./scripts;
  hyprlandUser = ./hyprland-user;
in
{
  imports = [
    ../../../modules/home/terminals.nix
    ../../../modules/home/coding-agents
    ../../../modules/shared/desktop
    ../../../modules/shared/desktop/wm/hyprland
    ../../../modules/shared/vscode
    ../../../modules/home/waybar-audio-control.nix
    ../../../modules/home/rvm-webcam.nix
    ../../../modules/home/mangohud
    ./hypridle.nix
  ];

  home.packages =
    with pkgs;
    [
      obsidian
      python3
      nodejs
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.google-chrome
      pkgs.zathura
    ];

  services.xembed-sni-proxy.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "xybschin";
      user.email = "hello@bjarneschindler.dev";
      extraConfig.credential.helper = "store";
      color.ui = true;
      init.defaultBranch = "main";
    };
  };

  xdg.configFile."hypr/binds.user.lua".source = "${hyprlandUser}/binds.user.lua";
  xdg.configFile."hypr/rules.user.lua".source = "${hyprlandUser}/rules.user.lua";
  xdg.configFile."hypr/autostart.user.lua".source = "${hyprlandUser}/autostart.user.lua";
  xdg.configFile."hypr/settings.user.lua".source = "${hyprlandUser}/settings.user.lua";
  xdg.configFile."hypr/scripts/rofi-monitor-menu".source = "${scripts}/rofi-monitor-menu";
  xdg.configFile."hypr/scripts/monitor-config".source = "${scripts}/monitor-config";
  # Cap VRAM reported to DXVK games, leaving ~512 MiB for compositor and other GPU apps.
  # RTX 2070 Super has 8192 MiB total; 7680 = 7.5 GB.
  home.file.".config/dxvk.conf".text = ''
    dxgi.maxDeviceMemory = 7680
  '';
}
