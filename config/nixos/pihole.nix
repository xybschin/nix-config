{ ... }:
{
  config.my.features.nixos.pihole =
    { config, ... }:
    {
      services.pihole-ftl = {
        enable = true;
        # Reachable only via the trusted wg0 interface; the WAN/LAN
        # firewall stays closed on 53 and 8080.
        openFirewallDNS = false;
        openFirewallWebserver = false;
        useDnsmasqConfig = true;

        settings = {
          dns = {
            listeningMode = "ALL";
            upstreams = [
              "9.9.9.9"
              "2620:fe::fe"
            ];
          };
          webserver.port = "8080";
        };

        lists = [
          {
            description = "StevenBlack hosts";
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            enabled = true;
            type = "block";
          }
        ];
      };

      # Local DNS records for VPN clients. Everything now lives on the
      # tunnel address. TODO(Phase 0): verify against the old box
      # (/etc/pihole/hosts, gravity.db custom records) and adjust.
      services.dnsmasq.settings.address = [
        "/pihole.bjarneschindler.dev/10.0.3.1"
        "/traefik.bjarneschindler.dev/10.0.3.1"
        "/wg.bjarneschindler.dev/10.0.3.1"
        "/vpn.bjarneschindler.dev/10.0.3.1"
      ];

      # Pi-hole v6 reads FTLCONF_* environment variables over pihole.toml,
      # so the UI password stays out of the world-readable nix store.
      sops.secrets.pihole_webserver_password = { };
      sops.templates."pihole-ftl.env".content = ''
        FTLCONF_webserver_api_password=${config.sops.placeholder.pihole_webserver_password}
      '';
      systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = [
        config.sops.templates."pihole-ftl.env".path
      ];
    };
}
