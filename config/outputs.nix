{
  config,
  lib,
  inputs,
  ...
}:
let
  homeModules =
    host:
    (map (f: config.my.features.home.${f}) host.home.features)
    ++ host.home.extraModules
    ++ [ host.home.configuration ];

  homeUser = host: { ... }: {
    home.username = lib.mkDefault host.username;
    home.homeDirectory = lib.mkDefault (
      if host.system == "aarch64-darwin" then "/Users/${host.username}" else "/home/${host.username}"
    );
    nixpkgs.config.allowUnfree = true;
  };

  mkNixos =
    hostname: host:
    inputs.nixpkgs.lib.nixosSystem {
      system = host.system;
      specialArgs = {
        inherit inputs;
        hostUser = host.username;
        configRoot = config.my.configRoot;
      };
      modules =
        (map (f: config.my.features.nixos.${f}) host.nixos.features)
        ++ host.nixos.extraModules
        ++ [
          host.nixos.configuration
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                configRoot = config.my.configRoot;
                isWsl = host.isWsl;
              };
              sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
              users.${host.username} = {
                imports = homeModules host ++ [ (homeUser host) ];
              };
            };
          }
        ];
    };

  mkDarwin =
    hostname: host:
    inputs.darwin.lib.darwinSystem {
      system = host.system;
      specialArgs = {
        inherit inputs;
        hostUser = host.username;
        configRoot = config.my.configRoot;
      };
      modules =
        (map (f: config.my.features.darwin.${f}) host.darwin.features)
        ++ host.darwin.extraModules
        ++ [
          host.darwin.configuration
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                configRoot = config.my.configRoot;
                isWsl = host.isWsl;
              };
              users.${host.username} = {
                imports = homeModules host ++ [ (homeUser host) ];
              };
            };
          }
        ];
    };

  mkHome =
    username: host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${host.system};
      extraSpecialArgs = {
        inherit inputs;
        configRoot = config.my.configRoot;
        isWsl = host.isWsl;
      };
      modules = [ inputs.sops-nix.homeManagerModules.sops ] ++ homeModules host ++ [ (homeUser host) ];
    };
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs mkNixos (
      lib.filterAttrs (_: host: host.system == "x86_64-linux") config.my.hosts
    );
    darwinConfigurations = lib.mapAttrs mkDarwin (
      lib.filterAttrs (_: host: host.system == "aarch64-darwin") config.my.hosts
    );
    homeConfigurations = lib.mapAttrs' (
      name: host: lib.nameValuePair "${host.username}@${name}" (mkHome host.username host)
    ) config.my.hosts;
  };
}
