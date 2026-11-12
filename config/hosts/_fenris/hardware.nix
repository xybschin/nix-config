{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
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
    "ntsync"
  ];

  # CachyOS kernel tuned for Zen 3 (5800X3D): x86_64-v3, no LTO. The `pinned`
  # overlay reuses the flake's own nixpkgs revision, which is what the Hydra
  # builds in cache.lantian.pub were made from.
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  nix.settings = {
    substituters = [ "https://cache.lantian.pub/lantian" ];
    trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2418fd5a-e4f8-4074-98f0-2f61c1ebe083";
    fsType = "ext4";
  };

  fileSystems."/mnt/steam-library" = {
    device = "/dev/disk/by-uuid/d69827d6-b0ff-4195-9f36-df90a10cfaef";
    fsType = "ext4";
    options = [
      "users"
      "nofail"
      "exec"
      "noatime"
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
