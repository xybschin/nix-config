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
    MOZ_ENABLE_WAYLAND = "1";
    NVD_BACKEND = "direct";
  };

  environment.systemPackages = with pkgs; [
    libva
    libva-utils
    nvidia-vaapi-driver
  ];
}
