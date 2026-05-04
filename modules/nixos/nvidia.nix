{ pkgs, ... }:

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

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    NVD_BACKEND = "direct";
    __GL_GSYNC_ALLOWED = "0";
    __GL_SYNC_TO_VBLANK = "0";
  };

  environment.systemPackages = with pkgs; [
    libva
    libva-utils
    nvidia-vaapi-driver
    nvtopPackages.nvidia
  ];
}
