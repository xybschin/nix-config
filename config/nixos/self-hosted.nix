{ config, ... }:
let
  # Sub-features consumed through the registry, like shared.desktop pulls
  # shared.stylix (config/ is flake-level here, so the host's `config` inside
  # the deferred module cannot see my.features).
  features = config.my.features.nixos;
in
{
  # The self-hosted stack as one unit: the pieces below are only ever useful
  # together, are wired to each other here, and have never been opted into
  # separately. A host runs the stack by opting into `self-hosted`.
  config.my.features.nixos.self-hosted =
    { config, ... }:
    {
      imports = [
        features.server
        features.podman
        features.infra-network
        features.wireguard-server
        features.pihole
        features.traefik
      ];

      # The one place the WireGuard and infra networks meet: peers get the
      # infra DNS and subnet routed through the tunnel, and the infra network
      # accepts them on whatever interface the WireGuard server came up as.
      my.wireguard.server = {
        clientDns = config.my.infra.services.pihole.ip;
        clientRoutes = [ config.my.infra.subnet ];
      };
      my.infra.vpnInterface = config.my.wireguard.server.interface;
    };
}
