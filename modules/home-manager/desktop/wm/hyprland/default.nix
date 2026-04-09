{
  pkgs,
  ...
}:
let
  scripts = builtins.path {
    path = ./scripts;
    name = "hprland-scripts";
  };
in
{
  imports = [
    ./env.nix
    ./binds.nix
    ./rules.nix
    (import ./settings.nix { inherit scripts; })
    ./hyprpaper
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
