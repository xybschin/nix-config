{ ... }:
{
  config.my.features.nixos.usb-auto-mount = { pkgs, ... }: {
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      ntfs3g
    ];
  };
}
