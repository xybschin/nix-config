{
  config,
  lib,
  inputs,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  features = config.my.features.nixos;

  # Evaluate a minimal NixOS config; only the lazily-read parts below are
  # ever forced, so nothing is built.
  eval =
    {
      withPodman ? true,
      infra ? { },
    }:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        features.infra-network
        { my.infra = infra; }
        {
          nixpkgs.hostPlatform = system;
          system.stateVersion = "25.11";
          virtualisation.oci-containers.containers.a.image = "example/a";
          virtualisation.oci-containers.containers.b.image = "example/b";
        }
      ]
      ++ lib.optional withPodman features.podman;
    }).config;

  failures =
    cfg: lib.filter (a: !a.assertion && lib.hasPrefix "infra-network:" a.message) cfg.assertions;

  svc = ip: {
    inherit ip;
    vpnPorts = [
      {
        proto = "tcp";
        port = 443;
      }
    ];
  };

  good = eval {
    infra.services = {
      a = svc "10.0.2.2";
      b = (svc "10.0.2.3") // {
        vpnPorts = [
          {
            proto = "udp";
            port = 53;
          }
        ];
      };
    };
  };

  rejects = args: failures (eval args) != [ ];

  tests = {
    "valid services produce no failing assertions" = failures good == [ ];
    "ingress rule per vpn port" =
      lib.hasInfix ''iifname "wg0" oifname "br-infra" ip daddr 10.0.2.2 tcp dport 443 accept'' good.networking.firewall.extraForwardRules
      && lib.hasInfix ''iifname "wg0" oifname "br-infra" ip daddr 10.0.2.3 udp dport 53 accept'' good.networking.firewall.extraForwardRules;
    "egress and intra-bridge rules" =
      lib.hasInfix ''iifname "br-infra" oifname "eth0" accept'' good.networking.firewall.extraForwardRules
      && lib.hasInfix ''iifname "br-infra" oifname "br-infra" accept'' good.networking.firewall.extraForwardRules;
    "container joins the network with its ip" =
      good.virtualisation.oci-containers.containers.a.networks == [ "infra" ]
      && lib.elem "--ip=10.0.2.2" good.virtualisation.oci-containers.containers.a.extraOptions;
    "container unit waits for the network" =
      good.systemd.services.podman-a.requires == [ "podman-network-infra.service" ];
    "interface names follow options" =
      let
        cfg = eval {
          infra = {
            vpnInterface = "wg9";
            uplinkInterface = "ens3";
            services.a = svc "10.0.2.2";
          };
        };
        rules = cfg.networking.firewall.extraForwardRules;
      in
      lib.hasInfix ''iifname "wg9" oifname "br-infra"'' rules
      && lib.hasInfix ''oifname "ens3" accept'' rules;
    "rejects ip outside the subnet" = rejects { infra.services.a = svc "10.0.9.2"; };
    "rejects the gateway ip" = rejects { infra.services.a = svc "10.0.2.1"; };
    "rejects malformed ip" = rejects { infra.services.a = svc "10.0.2"; };
    "rejects duplicate ips" = rejects {
      infra.services = {
        a = svc "10.0.2.2";
        b = svc "10.0.2.2";
      };
    };
    "rejects missing podman feature" = rejects {
      withPodman = false;
      infra.services.a = svc "10.0.2.2";
    };
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) tests);
in
{
  flake.checks.${system}.infra-network =
    if failed == [ ] then
      pkgs.runCommand "infra-network-check" { } "touch $out"
    else
      throw "infra-network check failed:\n  - ${lib.concatStringsSep "\n  - " failed}";
}
