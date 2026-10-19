{ ... }:
{
  # Traefik as an OCI container on the infra network. Routing
  # uses the file provider only: no container socket is mounted, since a
  # podman socket in a container is root on the host. Backends are reached
  # by their static container IPs.
  config.my.features.nixos.traefik =
    { config, pkgs, ... }:
    let
      certDomain = "bjarneschindler.dev";
      # Host group that can read the cert; the container joins it by gid.
      certGid = 2001;

      yaml = pkgs.formats.yaml { };

      staticConfig = yaml.generate "traefik.yml" {
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };
          websecure.address = ":443";
        };
        api.dashboard = true;
        log.level = "WARN";
        providers.file.filename = "/etc/traefik/dynamic.yml";
      };

      dynamicConfig = yaml.generate "dynamic.yml" {
        http = {
          routers.pihole = {
            rule = "Host(`pihole.${certDomain}`)";
            entryPoints = [ "websecure" ];
            tls = { };
            middlewares = [ "pihole-redirect" ];
            service = "pihole";
          };
          middlewares.pihole-redirect.redirectRegex = {
            regex = "^https://pihole\\.${builtins.replaceStrings [ "." ] [ "\\." ] certDomain}/?$";
            replacement = "https://pihole.${certDomain}/admin";
            permanent = true;
          };
          services.pihole.loadBalancer.servers = [ { url = "http://10.0.2.2:8080"; } ];

          routers.traefik = {
            rule = "Host(`traefik.${certDomain}`)";
            entryPoints = [ "websecure" ];
            tls = { };
            service = "api@internal";
          };
        };
        tls.stores.default.defaultCertificate = {
          certFile = "/certs/fullchain.pem";
          keyFile = "/certs/key.pem";
        };
      };
    in
    {
      # DNS-01 via deSEC. bjarneschindler.dev is delegated to deSEC's
      # nameservers (set at the registrar), so lego writes the challenge TXT
      # records straight into the zone through the deSEC API.
      security.acme = {
        acceptTerms = true;
        defaults.email = "hello@bjarneschindler.dev";
        certs.${certDomain} = {
          domain = certDomain;
          extraDomainNames = [ "*.${certDomain}" ];
          dnsProvider = "desec";
          # Don't trust the provider's resolver for the propagation check:
          # it caches stale delegations after nameserver changes.
          dnsResolver = "1.1.1.1:53";
          environmentFile = config.sops.templates."desec-acme.env".path;
          group = "traefik-certs";
          reloadServices = [ "podman-traefik.service" ];
        };
      };
      users.groups.traefik-certs.gid = certGid;

      sops.secrets.desec_token = { };
      sops.templates."desec-acme.env".content = ''
        DESEC_TOKEN=${config.sops.placeholder.desec_token}
      '';

      virtualisation.oci-containers.containers.traefik = {
        # Major tag: follows v3.x, never jumps to a breaking v4.
        image = "docker.io/library/traefik:v3";
        labels."io.containers.autoupdate" = "registry";
        volumes = [
          "${staticConfig}:/etc/traefik/traefik.yml:ro"
          "${dynamicConfig}:/etc/traefik/dynamic.yml:ro"
          "/var/lib/acme/${certDomain}:/certs:ro"
        ];
        extraOptions = [
          # Unprivileged: nobody + cert-reader group, no capabilities.
          "--user=65534:${toString certGid}"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
          "--read-only"
          "--pids-limit=256"
          # Allow binding :80/:443 without NET_BIND_SERVICE.
          "--sysctl=net.ipv4.ip_unprivileged_port_start=80"
        ];
      };

      systemd.services.podman-traefik = {
        # The cert must exist before traefik can serve it (first boot).
        wants = [ "acme-${certDomain}.service" ];
        after = [ "acme-${certDomain}.service" ];
      };

      # VPN clients -> traefik only.
      my.infra.services.traefik = {
        ip = "10.0.2.3";
        vpnPorts = [
          {
            proto = "tcp";
            port = 80;
          }
          {
            proto = "tcp";
            port = 443;
          }
        ];
      };
    };
}
