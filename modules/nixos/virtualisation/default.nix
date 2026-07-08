{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.virtualisation.enable = lib.mkEnableOption "Virtualisation";

  config = lib.mkIf config.my.virtualisation.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;

    users.groups.libvirtd.members = builtins.attrNames config.snowfallorg.users;
    users.groups.kvm.members = builtins.attrNames config.snowfallorg.users;

    environment.systemPackages = with pkgs; [
      gnome-boxes
      dnsmasq
      phodav
    ];
  };
}
