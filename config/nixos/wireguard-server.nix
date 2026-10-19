{ ... }:
{
  # The WireGuard server: one definition of the address plan, consumed by the
  # NixOS config here and by scripts/wg-add-peer.sh (through `clientInfo` and
  # `allocate`, via `nix eval`). Peers come from a registry file the host
  # passes in; each peer's preshared key lives in sops as
  # `wireguard_psk_<name>`, which is checked at evaluation time.
  #
  # Needs sops-nix (`sops.defaultSopsFile`, `sops.secrets`).
  config.my.features.nixos.wireguard-server =
    {
      config,
      lib,
      inputs,
      ...
    }:
    let
      cfg = config.my.wireguard.server;
      ipv4 = import ../_lib/ipv4.nix { inherit lib; };

      # Managed by scripts/wg-add-peer.sh: one entry per device with its tunnel
      # address, public key and optional LAN behind it.
      peers = builtins.fromJSON (builtins.readFile cfg.peersFile);
      usedNames = map (p: p.name) peers;
      usedAddresses = map (p: p.address) peers;

      pskPrefix = "wireguard_psk_";
      pskKey = name: "${pskPrefix}${name}";
      # sops keeps key names in cleartext, so presence is checkable here.
      secretsText = "\n" + builtins.readFile config.sops.defaultSopsFile;
      hasPsk = name: lib.hasInfix "\n${pskKey name}:" secretsText;

      validName = n: builtins.match "[a-z0-9][a-z0-9_-]*" n != null;
      validAddress = a: ipv4.isIpv4 a && ipv4.inSubnet cfg.subnet a && a != cfg.serverAddress;

      nextAddress = lib.findFirst (a: a != cfg.serverAddress && !(lib.elem a usedAddresses)) null (
        ipv4.hostsOf cfg.subnet
      );

      # Pick (or validate) the tunnel address for a new peer.
      allocate =
        {
          name,
          address ? null,
        }:
        if !validName name then
          throw "invalid peer name '${name}' (use a-z, 0-9, _ and -)"
        else if lib.elem name usedNames then
          throw "peer '${name}' already exists"
        else if address == null then
          if nextAddress == null then throw "no free address in ${cfg.subnet}" else nextAddress
        else if !validAddress address then
          throw "address ${address} is not a usable address in ${cfg.subnet}"
        else if lib.elem address usedAddresses then
          throw "address ${address} is already in use"
        else
          address;

      # Repo-relative, so scripts can find the files in the work tree.
      repoRelative = p: lib.removePrefix "${inputs.self}/" (toString p);
    in
    {
      options.my.wireguard.server = {
        interface = lib.mkOption {
          type = lib.types.str;
          default = "wg0";
        };
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "10.0.3.0/24";
          description = "Tunnel subnet (IPv4 CIDR).";
        };
        serverAddress = lib.mkOption {
          type = lib.types.str;
          default = "10.0.3.1";
          description = "The server's own tunnel address.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 51820;
        };
        endpointHost = lib.mkOption {
          type = lib.types.str;
          description = "Public hostname clients connect to.";
        };
        peersFile = lib.mkOption {
          type = lib.types.path;
          description = "JSON registry of peers, edited by scripts/wg-add-peer.sh.";
        };
        clientDns = lib.mkOption {
          type = lib.types.str;
          description = "DNS server written into client configs.";
        };
        clientRoutes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Networks clients route through the tunnel; the server address is added.";
        };
        homeLan = lib.mkOption {
          type = lib.types.str;
          default = "10.0.1.0/24";
          description = "Home LAN a client may additionally route through the tunnel.";
        };

        clientInfo = lib.mkOption {
          type = lib.types.attrs;
          readOnly = true;
          internal = true;
          description = "Everything scripts/wg-add-peer.sh needs to know.";
        };
        allocate = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          internal = true;
          description = "{ name, address ? null } -> tunnel address, or throws.";
        };
      };

      config = {
        my.wireguard.server = {
          inherit allocate;
          clientInfo = {
            endpoint = "${cfg.endpointHost}:${toString cfg.port}";
            dns = cfg.clientDns;
            routes = cfg.clientRoutes ++ [ "${cfg.serverAddress}/32" ];
            inherit (cfg) homeLan;
            prefixLength = ipv4.prefixOf cfg.subnet;
            peersFile = repoRelative cfg.peersFile;
            secretsFile = repoRelative config.sops.defaultSopsFile;
            inherit pskPrefix;
          };
        };

        assertions = [
          {
            assertion = ipv4.isIpv4 cfg.serverAddress && ipv4.inSubnet cfg.subnet cfg.serverAddress;
            message = "wireguard-server: serverAddress ${cfg.serverAddress} is not inside ${cfg.subnet}.";
          }
          {
            assertion = lib.length usedNames == lib.length (lib.unique usedNames);
            message = "wireguard-server: peer names must be unique.";
          }
          {
            assertion = lib.length usedAddresses == lib.length (lib.unique usedAddresses);
            message = "wireguard-server: peer addresses must be unique.";
          }
        ]
        ++ map (p: {
          assertion = validName p.name && validAddress p.address && hasPsk p.name;
          message = "wireguard-server: peer `${p.name}` needs a name of a-z, 0-9, _ and -, an address inside ${cfg.subnet} (not ${cfg.serverAddress}), and a `${pskKey p.name}` key in sops.";
        }) peers;

        networking.wireguard = {
          enable = true;
          interfaces.${cfg.interface} = {
            ips = [ "${cfg.serverAddress}/${toString (ipv4.prefixOf cfg.subnet)}" ];
            listenPort = cfg.port;
            privateKeyFile = config.sops.secrets.wireguard_private_key.path;
            peers = map (p: {
              inherit (p) publicKey;
              presharedKeyFile = config.sops.secrets.${pskKey p.name}.path;
              # Tunnel address, plus any LAN routed behind the peer.
              allowedIPs = [ "${p.address}/32" ] ++ (p.lan or [ ]);
            }) peers;
          };
        };

        # The port is opened on the WAN here; the interface itself is fully
        # trusted so clients reach the local services without further rules.
        networking.firewall = {
          allowedUDPPorts = [ cfg.port ];
          trustedInterfaces = [ cfg.interface ];
          # VPN clients <-> home LAN behind a peer (routed over the tunnel).
          extraForwardRules = ''
            iifname "${cfg.interface}" oifname "${cfg.interface}" accept
          '';
        };

        sops.secrets = {
          wireguard_private_key = { };
        }
        // lib.listToAttrs (map (p: lib.nameValuePair (pskKey p.name) { }) peers);
      };
    };
}
