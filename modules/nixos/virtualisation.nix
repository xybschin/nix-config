{ pkgs, user, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;

  users.groups.libvirtd.members = [ user ];
  users.groups.kvm.members = [ user ];

  environment.systemPackages = with pkgs; [
    gnome-boxes
    dnsmasq
    phodav
  ];
}
