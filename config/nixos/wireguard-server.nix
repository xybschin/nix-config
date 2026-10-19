{ ... }:
{
  config.my.features.nixos.wireguard-server =
    { config, lib, ... }:
    let
      # Managed by scripts/wg-add-peer.sh: one entry per device with its tunnel
      # address, public key and optional LAN behind it. The preshared key of
      # each peer lives in sops as wireguard_psk_<name>.
      peers = builtins.fromJSON (builtins.readFile ../hosts/_atlas/wg-peers.json);
    in
    {
      networking.wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = [ "10.0.3.1/24" ];
          listenPort = 51820;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          peers = map (p: {
            inherit (p) publicKey;
            presharedKeyFile = config.sops.secrets."wireguard_psk_${p.name}".path;
            # Tunnel address, plus any LAN routed behind the peer.
            allowedIPs = [ "${p.address}/32" ] ++ (p.lan or [ ]);
          }) peers;
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

      sops.secrets = {
        wireguard_private_key = { };
      }
      // lib.listToAttrs (map (p: lib.nameValuePair "wireguard_psk_${p.name}" { }) peers);
    };
}
