{ ... }:
{
  config.my.features.nixos.wireguard-server =
    { config, ... }:
    {
      networking.wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = [ "10.0.3.1/24" ];
          listenPort = 51820;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          peers = [
            # FRITZ!Box 7530 AX (was wg-easy client 10.0.3.4)
            {
              publicKey = "HLiNC/jnmdm5VnP8VxIlkFWg6FN4gXEw1oE4VvaRXV8=";
              presharedKeyFile = config.sops.secrets.wireguard_psk_fritzbox.path;
              # Tunnel address plus the home LAN behind the FRITZ!Box, so other
              # VPN clients can reach it.
              allowedIPs = [
                "10.0.3.4/32"
                "10.0.1.0/24"
              ];
            }
            # TODO: copy the remaining peers from the old box's wg-easy
            # database (~/infra/etc/wireguard/wg0.json), one entry each.
          ];
        };
      };

      # 51820/udp is opened on the WAN by the server feature's firewall
      # settings; wg0 itself is fully trusted so clients reach the
      # local services (pihole, traefik) without further rules.
      networking.firewall = {
        allowedUDPPorts = [ 51820 ];
        trustedInterfaces = [ "wg0" ];
        # VPN clients <-> home LAN behind a peer (routed over wg0).
        extraForwardRules = ''
          iifname "wg0" oifname "wg0" accept
        '';
      };

      sops.secrets.wireguard_private_key = { };
      sops.secrets.wireguard_psk_fritzbox = { };
    };
}
