{
  pkgs,
  ...
}:
{
  imports = [
    ./env.nix
    ./binds.nix
    ./rules.nix
    ./settings.nix
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

  services.hyprpolkitagent.enable = true;
}
