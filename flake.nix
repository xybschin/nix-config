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

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:dan-online/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      nix-darwin,
      claude-code,
      opencode,
      apple-fonts,
      ...
    }@inputs:
    let
      configRoot = builtins.getEnv "CONFIG_ROOT";
      overlays = [
        claude-code.overlays.default
        opencode.overlays.default
      ];
      specialArgs = {
        inherit
          inputs
          nixpkgs
          overlays
          configRoot
          home-manager
          nixos-wsl
          nix-darwin
          apple-fonts
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

      darwinConfigurations."bjarne@macbook" = mkSystem "macbook" "bjarne" {
        system = "aarch64-darwin";
      };
    };
}
