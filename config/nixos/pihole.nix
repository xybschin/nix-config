{ ... }:
{
  # Pi-hole as an OCI container on the infra network, like the old VPS.
  # Nothing is published to the host; WireGuard clients reach it by routing
  # to the container IP (see the infra-network feature).
  config.my.features.nixos.pihole =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      traefikIp = config.my.infra.services.traefik.ip;
      # Baseline local DNS records for VPN clients; traefik fronts everything.
      seedHosts = ''[ "${traefikIp} pihole.bjarneschindler.dev", "${traefikIp} traefik.bjarneschindler.dev" ]'';
      seedMarker = "/var/lib/pihole/.dns-hosts-seeded";
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
          # IPv4 only: the infra network has no IPv6, so a v6 upstream just
          # fails with "Network unreachable".
          FTLCONF_dns_upstreams = "9.9.9.9;149.112.112.112";
          FTLCONF_webserver_port = "8080";
          # Deliberately no FTLCONF_dns_hosts: any FTLCONF_* var is read-only
          # in the web UI. Local DNS records are managed in the UI and persist
          # in /var/lib/pihole/pihole.toml; the baseline is seeded once below.
        };
        # Pi-hole v6 reads FTLCONF_* env over pihole.toml; the password stays
        # out of the world-readable nix store.
        environmentFiles = [ config.sops.templates."pihole.env".path ];
        extraOptions = [ "--pids-limit=512" ];
      };

      # Seed the baseline records once, before the container starts, by running
      # pihole-FTL in a throwaway container on the same volume. The marker
      # makes it one-shot, so records later edited or deleted in the web UI
      # are never overwritten. Failure is non-fatal: DNS must still come up.
      systemd.services.podman-pihole.preStart = lib.mkAfter ''
        if [ ! -e ${seedMarker} ]; then
          if ${pkgs.podman}/bin/podman run --rm --network=none \
              --volume /var/lib/pihole:/etc/pihole \
              --entrypoint pihole-FTL \
              ${config.virtualisation.oci-containers.containers.pihole.image} \
              --config dns.hosts '${seedHosts}'; then
            touch ${seedMarker}
          else
            echo "pihole: seeding dns.hosts failed, continuing without" >&2
          fi
        fi
      '';

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
