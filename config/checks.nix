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
    "infra: valid services produce no failing assertions" = failures good == [ ];
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

  # ---- wireguard-server ----------------------------------------------------

  wgPeers = builtins.toFile "peers.json" (
    builtins.toJSON [
      {
        name = "laptop";
        address = "10.0.3.2";
        publicKey = "pubA";
      }
      {
        name = "router";
        address = "10.0.3.4";
        publicKey = "pubB";
        lan = [ "10.0.1.0/24" ];
      }
    ]
  );

  wgSecrets = keys: builtins.toFile "secrets.yaml" (lib.concatMapStrings (k: "${k}: ENC[x]\n") keys);

  allKeys = [
    "wireguard_private_key"
    "wireguard_psk_laptop"
    "wireguard_psk_router"
  ];

  evalWg =
    {
      peers ? wgPeers,
      keys ? allKeys,
      server ? { },
    }:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        inputs.sops-nix.nixosModules.sops
        features.wireguard-server
        {
          nixpkgs.hostPlatform = system;
          system.stateVersion = "25.11";
          sops.defaultSopsFile = wgSecrets keys;
          my.wireguard.server = {
            endpointHost = "vpn.example.org";
            clientDns = "10.0.2.2";
            clientRoutes = [ "10.0.2.0/24" ];
            peersFile = peers;
          }
          // server;
        }
      ];
    }).config;

  wgFailures =
    cfg: lib.filter (a: !a.assertion && lib.hasPrefix "wireguard-server:" a.message) cfg.assertions;
  wgRejects = args: wgFailures (evalWg args) != [ ];
  wg = evalWg { };
  wgs = wg.my.wireguard.server;
  allocates = args: (builtins.tryEval (wgs.allocate args)).success;

  wgTests = {
    "wg: valid registry has no failing assertions" = wgFailures wg == [ ];
    "wg: peers become allowedIPs, with LANs behind them" =
      map (p: p.allowedIPs) wg.networking.wireguard.interfaces.wg0.peers == [
        [ "10.0.3.2/32" ]
        [
          "10.0.3.4/32"
          "10.0.1.0/24"
        ]
      ];
    "wg: server address and port" =
      wg.networking.wireguard.interfaces.wg0.ips == [ "10.0.3.1/24" ]
      && wg.networking.wireguard.interfaces.wg0.listenPort == 51820
      && wg.networking.firewall.allowedUDPPorts == [ 51820 ];
    "wg: psk secret per peer" = lib.all (k: wg.sops.secrets ? ${k}) [
      "wireguard_psk_laptop"
      "wireguard_psk_router"
    ];
    "wg: clientInfo" =
      wgs.clientInfo.endpoint == "vpn.example.org:51820"
      && wgs.clientInfo.dns == "10.0.2.2"
      &&
        wgs.clientInfo.routes == [
          "10.0.2.0/24"
          "10.0.3.1/32"
        ]
      && wgs.clientInfo.prefixLength == 24
      && wgs.clientInfo.pskPrefix == "wireguard_psk_";
    "wg: next free address skips used and server" = wgs.allocate { name = "new"; } == "10.0.3.3";
    "wg: explicit free address is accepted" =
      wgs.allocate {
        name = "new";
        address = "10.0.3.50";
      } == "10.0.3.50";
    "wg: allocation rejects duplicate name" = !allocates { name = "laptop"; };
    "wg: allocation rejects used address" =
      !allocates {
        name = "new";
        address = "10.0.3.2";
      };
    "wg: allocation rejects address outside subnet" =
      !allocates {
        name = "new";
        address = "10.0.9.2";
      };
    "wg: allocation rejects server address" =
      !allocates {
        name = "new";
        address = "10.0.3.1";
      };
    "wg: allocation rejects bad name" = !allocates { name = "Bad Name"; };
    "wg: rejects peer without psk in sops" = wgRejects {
      keys = [
        "wireguard_private_key"
        "wireguard_psk_laptop"
      ];
    };
    "wg: rejects peer address outside subnet" = wgRejects {
      peers = builtins.toFile "peers.json" (
        builtins.toJSON [
          {
            name = "laptop";
            address = "10.0.9.2";
            publicKey = "pubA";
          }
        ]
      );
    };
    "wg: rejects duplicate peer addresses" = wgRejects {
      peers = builtins.toFile "peers.json" (
        builtins.toJSON [
          {
            name = "laptop";
            address = "10.0.3.2";
            publicKey = "pubA";
          }
          {
            name = "router";
            address = "10.0.3.2";
            publicKey = "pubB";
          }
        ]
      );
    };
    "wg: interface name follows option" =
      let
        cfg = evalWg { server.interface = "wg9"; };
      in
      cfg.networking.wireguard.interfaces ? wg9
      && lib.elem "wg9" cfg.networking.firewall.trustedInterfaces;
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) (tests // wgTests));
in
{
  flake.checks.${system}.network-features =
    if failed == [ ] then
      pkgs.runCommand "network-features-check" { } "touch $out"
    else
      throw "network-features check failed:\n  - ${lib.concatStringsSep "\n  - " failed}";
}
