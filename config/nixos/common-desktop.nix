{ ... }:
{
  config.my.features.nixos.common-desktop = { pkgs, ... }: {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    console.keyMap = "us";
    networking.networkmanager.enable = true;

    security.polkit.enable = true;

    zramSwap.enable = true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = with pkgs; [
      gparted
      gnumake
      wl-clipboard
    ];
  };
}
