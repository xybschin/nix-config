{
  inputs,
  ...
}:
{
  config.my.hosts.atlas = {
    system = "x86_64-linux";
    username = "moonz";
    isWsl = false;

    nixos.features = [
      "common"
      "server"
      "pihole"
      "traefik"
      "wireguard-server"
    ];
    nixos.extraModules = [
      ./_atlas/hardware.nix
      ./_atlas/disko.nix
      inputs.sops-nix.nixosModules.sops
      inputs.disko.nixosModules.disko
    ];
    nixos.configuration =
      { pkgs, ... }:
      {
        networking.hostName = "atlas";

        # Static network config — mirrors the VPS provider's cloud-init
        # settings (/etc/network/interfaces.d/50-cloud-init.cfg). No DHCP
        # server on this network; DHCP-only NixOS would boot without a link.
        networking = {
          useDHCP = false;
          interfaces.eth0 = {
            ipv4.addresses = [
              {
                address = "37.120.171.251";
                prefixLength = 22;
              }
            ];
            ipv6.addresses = [
              {
                address = "2a03:4000:6:5457:7494:11ff:fefd:d30";
                prefixLength = 64;
              }
            ];
          };
          defaultGateway = "37.120.168.1";
          defaultGateway6 = {
            address = "fe80::1";
            interface = "eth0";
          };
          nameservers = [
            "46.38.252.230"
            "46.38.225.230"
            "2a03:4000:8000::fce6"
          ];
        };

        sops = {
          defaultSopsFile = ../../secrets/atlas.yaml;
          age.keyFile = "/var/lib/sops-nix/age/keys.txt";
        };

        users.users.moonz = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          shell = pkgs.zsh;
          hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsuUETmjldV9vbB5kg3NlXNWeL5OL8VhX9qbGHMVsFo"
          ];
        };

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsuUETmjldV9vbB5kg3NlXNWeL5OL8VhX9qbGHMVsFo"
        ];
      };

    home.features = [ "global" ];
  };
}
