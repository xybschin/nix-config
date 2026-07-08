{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "bluetooth"
    "btusb"
    "kvm-amd"
    "v4l2loopback"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2418fd5a-e4f8-4074-98f0-2f61c1ebe083";
    fsType = "ext4";
  };

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="rvm-webcam" exclusive_caps=1
  '';

  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/871b1716-27b4-4dea-8452-05fe0cf89d43";
    fsType = "auto";
    options = [
      "users"
      "nofail"
      "exec"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B228-5B3A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
