{ ... }:
{
  config.my.features.nixos.virtualisation =
    {
      pkgs,
      hostUser,
      ...
    }:
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

      users.groups.libvirtd.members = [ hostUser ];
      users.groups.kvm.members = [ hostUser ];

      environment.systemPackages = with pkgs; [
        gnome-boxes
        virt-manager
        swtpm
        tpm2-tools
        dnsmasq
        phodav
      ];
    };
}
