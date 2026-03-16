{
  pkgs,
  ...
}:
{
  imports = [
    ./env.nix
    ./binds.nix
    # ./scripts.nix
    ./rules.nix
    ./settings.nix
    # ./hyprlock.nix
    ./hyprpaper
  ];

  home.packages = with pkgs; [
    hyprcursor
    hyprshutdown
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
  };

  services.hyprpolkitagent.enable = true;
}
