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

  # Workarounds for out-of-tree modules vs. aggregateModules (nixos-unstable
  # as of 2026-10-20). Drop each override once its upstream fix reaches the
  # channel.
  # - v4l2loopback: kernel.dev now ships System.map, so modules_install runs
  #   depmod and the package's modules.* files collide with the kernel's.
  #   https://github.com/NixOS/nixpkgs/issues/576406
  # - openrazer: installs no per-module .ko.cer, which aggregateModules now
  #   cats into modules.cer; an empty one is enough. Fixed on master by
  #   965f876a7 (https://github.com/NixOS/nixpkgs/issues/575192).
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3.extend (
    _final: prev: {
      v4l2loopback = prev.v4l2loopback.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -f $out/lib/modules/*/modules.*
        '';
      });
      openrazer = prev.openrazer.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for ko in $out/lib/modules/*/kernel/drivers/hid/*.ko; do
            touch "$ko.cer"
          done
        '';
      });
    }
  );
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
