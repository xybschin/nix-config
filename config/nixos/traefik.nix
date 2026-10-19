{ ... }:
{
  config.my.features.nixos.traefik =
    { config, ... }:
    let
      certDomain = "bjarneschindler.dev";
    in
    {
      # DNS-01 via the Netcup DNS API — independent of the server's IP family.
      security.acme = {
        acceptTerms = true;
        defaults.email = "hello@bjarneschindler.dev";
        certs.${certDomain} = {
          domain = certDomain;
          extraDomainNames = [ "*.${certDomain}" ];
          dnsProvider = "netcup";
          environmentFile = config.sops.templates."netcup-acme.env".path;
          reloadServices = [ "traefik" ];
        };
      };

      sops.secrets.netcup_customer_number = { };
      sops.secrets.netcup_api_key = { };
      sops.secrets.netcup_api_password = { };
      sops.templates."netcup-acme.env".content = ''
        NETCUP_CUSTOMER_NUMBER=${config.sops.placeholder.netcup_customer_number}
        NETCUP_API_KEY=${config.sops.placeholder.netcup_api_key}
        NETCUP_API_PASSWORD=${config.sops.placeholder.netcup_api_password}
      '';

      services.traefik = {
        enable = true;
        staticConfigOptions = {
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
        };

        dynamicConfigOptions = {
          http.routers.pihole = {
            rule = "Host(`pihole.bjarneschindler.dev`)";
            entryPoints = [ "websecure" ];
            tls = { };
            middlewares = [ "pihole-redirect" ];
            service = "pihole";
          };
          http.middlewares.pihole-redirect.redirectRegex = {
            regex = "^https://pihole\\.bjarneschindler\\.dev/?$";
            replacement = "https://pihole.bjarneschindler.dev/admin";
            permanent = true;
          };
          http.services.pihole.loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];

          http.routers.traefik = {
            rule = "Host(`traefik.bjarneschindler.dev`)";
            entryPoints = [ "websecure" ];
            tls = { };
            service = "api@internal";
          };

          tls.stores.default.defaultCertificate = {
            certFile = "/var/lib/acme/${certDomain}/fullchain.pem";
            keyFile = "/var/lib/acme/${certDomain}/privkey.pem";
          };
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];

      # The cert must exist before traefik can serve it (first boot).
      systemd.services.traefik = {
        wants = [ "acme-${certDomain}.service" ];
        after = [ "acme-${certDomain}.service" ];
      };
    };
}
