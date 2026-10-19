{ ... }:
{
  # The infra network: a podman bridge whose containers have fixed IPs that
  # the host firewall and WireGuard clients route to directly. A feature
  # that runs on it declares one `my.infra.services.<name>` entry (the key
  # must equal the container name); this module wires the container onto
  # the bridge and generates the forward rules from it.
  #
  #   my.infra.services.pihole = {
  #     ip = "10.0.2.2";
  #     vpnPorts = [ { proto = "udp"; port = 53; } ];
  #   };
  #
  # Needs the `podman` feature. Service IPs are checked: inside the subnet,
  # not the gateway, unique.
  config.my.features.nixos.infra-network =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.infra;

      # Internal: nothing outside this module needs to vary them.
      bridge = "br-infra";
      network = "infra";
      networkUnit = "podman-network-${network}.service";

      ipv4 = import ../_lib/ipv4.nix { inherit lib; };
      inSubnet = ipv4.inSubnet cfg.subnet;

      ips = lib.mapAttrsToList (_: s: s.ip) cfg.services;

      ingressRules = lib.concatStringsSep "\n" (
        lib.concatLists (
          lib.mapAttrsToList (
            _: s:
            map (
              p:
              ''iifname "${cfg.vpnInterface}" oifname "${bridge}" ip daddr ${s.ip} ${p.proto} dport ${toString p.port} accept''
            ) s.vpnPorts
          ) cfg.services
        )
      );
    in
    {
      options.my.infra = {
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "10.0.2.0/24";
          description = "IPv4 subnet of the infra network.";
        };
        gateway = lib.mkOption {
          type = lib.types.str;
          default = "10.0.2.1";
          description = "Gateway address of the infra bridge on the host.";
        };
        vpnInterface = lib.mkOption {
          type = lib.types.str;
          default = "wg0";
          description = "Interface VPN clients arrive on.";
        };
        uplinkInterface = lib.mkOption {
          type = lib.types.str;
          default = "eth0";
          description = "Interface container egress leaves through.";
        };
        services = lib.mkOption {
          default = { };
          description = "Containers on the infra network, keyed by container name.";
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                ip = lib.mkOption {
                  type = lib.types.str;
                  description = "Fixed IPv4 address of the container.";
                };
                vpnPorts = lib.mkOption {
                  default = [ ];
                  description = "Ports VPN clients may reach on this service.";
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        proto = lib.mkOption {
                          type = lib.types.enum [
                            "tcp"
                            "udp"
                          ];
                        };
                        port = lib.mkOption { type = lib.types.port; };
                      };
                    }
                  );
                };
              };
            }
          );
        };
      };

      config = {
        assertions = [
          {
            # What the `podman` feature provides and the forward rules need.
            assertion = config.networking.nftables.enable && config.networking.firewall.filterForward;
            message = "infra-network: the `podman` feature is required (nftables with forward filtering).";
          }
          {
            assertion = ipv4.isIpv4 cfg.gateway && inSubnet cfg.gateway;
            message = "infra-network: gateway ${cfg.gateway} is not an IPv4 address inside ${cfg.subnet}.";
          }
          {
            assertion = lib.length ips == lib.length (lib.unique ips);
            message = "infra-network: service IPs must be unique (got ${lib.concatStringsSep ", " ips}).";
          }
        ]
        ++ lib.mapAttrsToList (name: s: {
          assertion = ipv4.isIpv4 s.ip && inSubnet s.ip && s.ip != cfg.gateway;
          message = "infra-network: service `${name}` ip ${s.ip} must be an IPv4 address inside ${cfg.subnet} and not the gateway ${cfg.gateway}.";
        }) cfg.services;

        # Egress, plus intra-bridge traffic. Netavark masquerades the subnet
        # itself, so no NAT rule is needed. Ingress per service follows.
        networking.firewall.extraForwardRules = ''
          iifname "${bridge}" oifname "${cfg.uplinkInterface}" accept
          iifname "${bridge}" oifname "${bridge}" accept
          ${ingressRules}
        '';

        virtualisation.oci-containers.containers = lib.mapAttrs (_: s: {
          networks = [ network ];
          extraOptions = [ "--ip=${s.ip}" ];
        }) cfg.services;

        systemd.services =
          lib.mapAttrs' (
            name: _:
            lib.nameValuePair "podman-${name}" {
              requires = [ networkUnit ];
              after = [ networkUnit ];
            }
          ) cfg.services
          // {
            # Equivalent of the compose `networks:` block on the old VPS.
            "podman-network-${network}" = {
              description = "Create the podman `${network}` network (${bridge})";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              path = [ pkgs.podman ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script = ''
                podman network exists ${network} || podman network create \
                  --driver bridge \
                  --subnet ${cfg.subnet} \
                  --gateway ${cfg.gateway} \
                  --interface-name ${bridge} \
                  --disable-dns \
                  ${network}
              '';
            };
          };
      };
    };
}
