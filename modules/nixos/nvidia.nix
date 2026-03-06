{ ... }:

{
  hardware = {
    nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement.enable = false;
    };

    opengl = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
