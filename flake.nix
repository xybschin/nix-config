{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inputs.opencode-flake.url = "github:aodhanhayter/opencode-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      ...
    }@inputs:
    let
      configRoot = builtins.getEnv "CONFIG_ROOT";
      overlays = [ ];
      specialArgs = {
        inherit
          inputs
          nixpkgs
          overlays
          configRoot
          home-manager
          nixos-wsl
          ;
        lib = nixpkgs.lib;
      };

      mkSystem = import ./lib/mksystem.nix specialArgs;
      mkStandalone = import ./lib/mkstandalone.nix specialArgs;
    in
    {
      nixosConfigurations."bjarne@nixvidia" = mkSystem "nixvidia" "bjarne" {
        system = "x86_64-linux";
      };

      nixosConfigurations."dev@nixvm" = mkSystem "nixvm" "dev" {
        system = "x86_64-linux";
      };

      nixosConfigurations."dev@nixwsl" = mkSystem "nixwsl" "dev" {
        system = "x86_64-linux";
      };

      homeConfigurations.dev = mkStandalone {
        user = "dev";
      };
    };
}
