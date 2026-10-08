{
  config,
  lib,
  inputs,
  ...
}:
let
  isDarwin = host: lib.hasSuffix "-darwin" host.system;

  # Everything a Home needs, independent of any System configuration, so the
  # same Home evaluates identically integrated and standalone. `specialArgs`
  # must stay separate from `modules`: features use `inputs` inside `imports`.
  homeFor = host: {
    specialArgs = {
      inherit inputs;
      configRoot = config.my.configRoot;
      hostUser = host.username;
      isWsl = host.isWsl;
    };
    modules = [
      inputs.sops-nix.homeManagerModules.sops
      {
        nixpkgs.overlays = [ inputs.self.overlays.default ];
        nixpkgs.config.allowUnfree = true;
        home.username = lib.mkDefault host.username;
        home.homeDirectory = lib.mkDefault (
          if isDarwin host then "/Users/${host.username}" else "/home/${host.username}"
        );
      }
    ]
    ++ (map (f: config.my.features.home.${f}) host.home.features)
    ++ host.home.extraModules
    ++ [ host.home.configuration ];
  };

  kindOf = host: if isDarwin host then "darwin" else "nixos";

  kinds = {
    nixos = {
      builder = inputs.nixpkgs.lib.nixosSystem;
      homeManager = inputs.home-manager.nixosModules.home-manager;
    };
    darwin = {
      builder = inputs.darwin.lib.darwinSystem;
      homeManager = inputs.home-manager.darwinModules.home-manager;
    };
  };

  mkSystem =
    _: host:
    let
      kind = kindOf host;
      hostKind = host.${kind};
      home = homeFor host;
    in
    kinds.${kind}.builder {
      system = host.system;
      specialArgs = {
        inherit inputs;
        hostUser = host.username;
        configRoot = config.my.configRoot;
      };
      modules =
        (map (f: config.my.features.${kind}.${f}) hostKind.features)
        ++ hostKind.extraModules
        ++ [
          hostKind.configuration
          kinds.${kind}.homeManager
          {
            home-manager = {
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = home.specialArgs;
              users.${host.username}.imports = home.modules;
            };
          }
        ];
    };

  mkHome =
    host:
    let
      home = homeFor host;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${host.system};
      extraSpecialArgs = home.specialArgs;
      modules = home.modules;
    };

  hostsOfKind = kind: lib.filterAttrs (_: host: kindOf host == kind) config.my.hosts;
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs mkSystem (hostsOfKind "nixos");
    darwinConfigurations = lib.mapAttrs mkSystem (hostsOfKind "darwin");
    homeConfigurations = lib.mapAttrs' (
      name: host: lib.nameValuePair "${host.username}@${name}" (mkHome host)
    ) (lib.filterAttrs (_: host: host.home.standalone) config.my.hosts);
  };
}
