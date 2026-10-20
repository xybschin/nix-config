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
  features' = config.my.features.home;

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
  # ---- monitors ------------------------------------------------------------

  monGen = import ./_lib/monitors.nix { inherit lib; };

  out =
    {
      name,
      mode ? null,
      position ? null,
      workspaces ? [ ],
      enabled ? true,
    }:
    {
      inherit
        name
        mode
        position
        workspaces
        enabled
        ;
      scale = 1;
    };

  monFixture = [
    {
      name = "wide";
      glyph = "\\U000F5000";
      outputs = [
        (out {
          name = "A-1";
          mode = "2560x1440@120";
          position = "0x0";
          workspaces = [
            3
            1
          ];
        })
        (out {
          name = "B-2";
          mode = "1920x1080@60";
          position = "2560x0";
          workspaces = [ 2 ];
        })
      ];
    }
    {
      name = "solo";
      glyph = "\\U000F5001";
      outputs = [
        (out {
          name = "A-1";
          mode = "2560x1440@120";
          position = "0x0";
          workspaces = [
            1
            2
            3
          ];
        })
        (out {
          name = "B-2";
          enabled = false;
        })
      ];
    }
  ];

  monLua = pkgs.writeText "monitors.lua" (
    monGen.renderLua {
      profiles = monFixture;
      alwaysDisabled = [ "C-3" ];
      gamingWorkspace = 3;
      stateFileName = "state";
      applyScript = "/bin/apply";
    }
  );

  monLuaRunner = pkgs.writeText "run.lua" ''
    local profile = arg[1]
    local mon, ws = {}, {}
    hl = {
      monitor = function(o) mon[#mon + 1] = o.output .. (o.disabled and " off" or (" " .. o.mode .. " " .. o.position)) end,
      workspace_rule = function(o)
        ws[#ws + 1] = o.workspace .. "@" .. o.monitor .. (o.gaps_in and " nogaps" or "")
      end,
      bind = function(key, action) print("bind " .. key) end,
      dsp = { focus = function(o) return o end },
      on = function(ev, fn) print("on " .. ev); fn() end,
      exec_cmd = function(c) print("exec " .. c) end,
    }
    dofile(arg[2])
    print(table.concat(mon, "; "))
    print(table.concat(ws, "; "))
  '';

  monExpected = {
    wide = ''
      bind SUPER + g
      on hyprland.start
      exec /bin/apply
      A-1 2560x1440@120 0x0; B-2 1920x1080@60 2560x0; C-3 off
      1@A-1; 3@A-1 nogaps; 2@B-2
    '';
    solo = ''
      bind SUPER + g
      on hyprland.start
      exec /bin/apply
      A-1 2560x1440@120 0x0; B-2 off; C-3 off
      1@A-1; 2@A-1; 3@A-1 nogaps
    '';
  };

  # Same profiles, but no gaming workspace: no global, no bind.
  monLuaNoGaming = pkgs.writeText "monitors-nogaming.lua" (
    monGen.renderLua {
      profiles = monFixture;
      alwaysDisabled = [ "C-3" ];
      gamingWorkspace = null;
      stateFileName = "state";
      applyScript = "/bin/apply";
    }
  );

  monExpectedNoGaming = ''
    on hyprland.start
    exec /bin/apply
    A-1 2560x1440@120 0x0; B-2 1920x1080@60 2560x0; C-3 off
    1@A-1; 3@A-1; 2@B-2
  '';

  monLuaCheck = pkgs.runCommand "monitors-lua-check" { nativeBuildInputs = [ pkgs.lua5_4 ]; } ''
    run() { # state-content [lua-file] -> output
      export XDG_STATE_HOME=$(mktemp -d)
      if [ -n "$1" ]; then echo "$1" > "$XDG_STATE_HOME/state"; fi
      lua ${monLuaRunner} "$1" "''${2:-${monLua}}"
    }
    expect() { # label state expected [lua-file]
      got=$(run "$2" "$4")
      if [ "$got" != "$3" ]; then
        printf 'FAIL %s\n--- got\n%s\n--- want\n%s\n' "$1" "$got" "$3"; exit 1
      fi
    }
    expect "state wide" wide ${lib.escapeShellArg (lib.removeSuffix "\n" monExpected.wide)}
    expect "state solo" solo ${lib.escapeShellArg (lib.removeSuffix "\n" monExpected.solo)}
    expect "unknown state falls back to the first profile" bogus ${lib.escapeShellArg (lib.removeSuffix "\n" monExpected.wide)}
    expect "missing state falls back to the first profile" "" ${lib.escapeShellArg (lib.removeSuffix "\n" monExpected.wide)}
    expect "no gaming workspace means no bind" wide ${lib.escapeShellArg (lib.removeSuffix "\n" monExpectedNoGaming)} ${monLuaNoGaming}
    touch $out
  '';

  evalMon =
    {
      profiles ? monFixture,
      gamingWorkspace ? null,
      rofi ? true,
    }:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        features'."shared.desktop.monitors"
        {
          home = {
            username = "t";
            homeDirectory = "/home/t";
            stateVersion = "25.11";
          };
          programs.rofi.enable = rofi;
          my.monitors = {
            inherit profiles gamingWorkspace;
          };
        }
      ];
    }).config;

  # homeManagerConfiguration throws when an assertion fails, so "rejected"
  # means evaluation fails; the valid case guards against unrelated failures.
  monAccepts = args: (builtins.tryEval (evalMon args).home.username).success;
  monRejects = args: !monAccepts args;

  withOutputs = os: [
    {
      name = "p";
      glyph = "\\U000F5000";
      outputs = os;
    }
  ];

  monTests = {
    "mon: valid profiles pass" = monAccepts { };
    "mon: rejects no profiles" = monRejects { profiles = [ ]; };
    "mon: rejects duplicate names" = monRejects {
      profiles = monFixture ++ [ (lib.head monFixture) ];
    };
    "mon: rejects enabled output without mode" = monRejects {
      profiles = withOutputs [
        (out {
          name = "A-1";
          position = "0x0";
        })
      ];
    };
    "mon: rejects a workspace pinned twice" = monRejects {
      profiles = withOutputs [
        (out {
          name = "A-1";
          mode = "m";
          position = "0x0";
          workspaces = [ 1 ];
        })
        (out {
          name = "B-2";
          mode = "m";
          position = "1x0";
          workspaces = [ 1 ];
        })
      ];
    };
    "mon: rejects a workspace on a disabled output" = monRejects {
      profiles = withOutputs [
        (out {
          name = "A-1";
          enabled = false;
          workspaces = [ 1 ];
        })
      ];
    };
    "mon: rejects missing rofi" = monRejects { rofi = false; };
    "mon: accepts gaming workspace pinned in every profile" = monAccepts { gamingWorkspace = 3; };
    "mon: accepts no gaming workspace" = monAccepts { gamingWorkspace = null; };
    "mon: rejects gaming workspace missing from a profile" = monRejects { gamingWorkspace = 4; };
  };

  monFailed = lib.attrNames (lib.filterAttrs (_: ok: !ok) monTests);

in
{
  flake.checks.${system} = {
    network-features =
      if failed == [ ] then
        pkgs.runCommand "network-features-check" { } "touch $out"
      else
        throw "network-features check failed:\n  - ${lib.concatStringsSep "\n  - " failed}";

    monitors =
      if monFailed == [ ] then
        monLuaCheck
      else
        throw "monitors check failed:\n  - ${lib.concatStringsSep "\n  - " monFailed}";
  };
}
