{ lib, ... }:
{
  # Single-disk UEFI VPS: GPT with ESP (vfat, /boot/efi), ext4 /boot,
  # ext4 root covering the rest of the drive. Adjust `device` if the VPS
  # exposes the disk as /dev/sda instead of /dev/vda.
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "512M";
            type = "EF00";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "umask=0077" ];
            };
          };
          boot = {
            size = "1G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
