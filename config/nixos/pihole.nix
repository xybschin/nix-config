{ ... }:
{
  # Pi-hole as an OCI container on the infra network, like the old VPS.
  # Nothing is published to the host; WireGuard clients reach it by routing
  # to the container IP (see the infra-network feature).
  config.my.features.nixos.pihole =
    { config, ... }:
    let
      traefikIp = config.my.infra.services.traefik.ip;
    in
    {
      virtualisation.oci-containers.containers.pihole = {
        # Moving tag, updated by podman-auto-update (see podman feature).
        image = "docker.io/pihole/pihole:latest";
        labels."io.containers.autoupdate" = "registry";
        capabilities = {
          NET_ADMIN = true;
          SYS_TIME = true;
          SYS_NICE = true;
        };
        volumes = [ "/var/lib/pihole:/etc/pihole" ];
        environment = {
          TZ = "Europe/Berlin";
          FTLCONF_dns_listeningMode = "ALL";
          FTLCONF_dns_upstreams = "9.9.9.9;2620:fe::fe";
          FTLCONF_webserver_port = "8080";
          # Local DNS records for VPN clients; traefik fronts everything.
          FTLCONF_dns_hosts = "${traefikIp} pihole.bjarneschindler.dev;${traefikIp} traefik.bjarneschindler.dev";
        };
        # Pi-hole v6 reads FTLCONF_* env over pihole.toml; the password stays
        # out of the world-readable nix store.
        environmentFiles = [ config.sops.templates."pihole.env".path ];
        extraOptions = [ "--pids-limit=512" ];
      };

      sops.secrets.pihole_webserver_password = { };
      sops.templates."pihole.env".content = ''
        FTLCONF_webserver_api_password=${config.sops.placeholder.pihole_webserver_password}
      '';

      systemd.tmpfiles.rules = [ "d /var/lib/pihole 0755 root root -" ];

      # VPN clients -> pihole DNS only.
      my.infra.services.pihole = {
        ip = "10.0.2.2";
        vpnPorts = [
          {
            proto = "udp";
            port = 53;
          }
          {
            proto = "tcp";
            port = 53;
          }
        ];
      };
    };
}
