{ ... }:

{
  hardware = {
    nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement.enable = false;
      nvidiaSettings = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
