{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.usb-auto-mount.enable = lib.mkEnableOption "USB auto-mounting (udisks2 + gvfs)";

  config = lib.mkIf config.my.usb-auto-mount.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      ntfs3g
    ];
  };
}
