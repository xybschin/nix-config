{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.common-desktop.enable = lib.mkEnableOption "Common desktop configuration";

  config = lib.mkIf config.my.common-desktop.enable {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    console.keyMap = "us";
    networking.networkmanager.enable = true;

    security = {
      polkit = {
        enable = true;
      };
    };

    zramSwap.enable = true;

    environment.systemPackages = with pkgs; [
      gparted
      gnumake
      wl-clipboard
    ];
  };
}
