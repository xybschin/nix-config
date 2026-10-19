{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Partitioning, fileSystems, and the ESP are handled by disko
  # (config/hosts/_atlas/disko.nix). UEFI VPS: GRUB installs to the
  # removable fallback path (\EFI\BOOT\BOOTX64.EFI), so booting works
  # even if NVRAM boot entries cannot be written.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;
  # ESP is mounted at /boot/efi (see disko.nix), not the default /boot
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # keep eth0-style interface names (matches the provider's cloud-init config)
  boot.kernelParams = [ "net.ifnames=0" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
