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
          # Public endpoint for client configs: 37.120.171.251:51820
          peers = [
            # TODO(Phase 0): copy peers from the old box's wg-easy database
            # (~/infra/etc/wireguard/wg0.json), one entry per device:
            # {
            #   publicKey = "<base64>";
            #   allowedIPs = [ "10.0.3.2/32" ];
            # }
          ];
        };
      };

      # 51820/udp is opened on the WAN by the server feature's firewall
      # settings; wg0 itself is fully trusted so clients reach the
      # local services (pihole, traefik) without further rules.
      networking.firewall = {
        allowedUDPPorts = [ 51820 ];
        trustedInterfaces = [ "wg0" ];
      };

      sops.secrets.wireguard_private_key = { };
    };
}
