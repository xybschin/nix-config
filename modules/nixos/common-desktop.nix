{ pkgs, ... }:

{
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

  boot.kernelPackages = pkgs.linuxPackages_latest;
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    gnumake
    wl-clipboard
  ];
}
