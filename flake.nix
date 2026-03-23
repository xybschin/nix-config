{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:dan-online/opencode-nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      opencode,
      ...
    }@inputs:
    let
      configRoot = builtins.getEnv "CONFIG_ROOT";
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
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
          ;
      };

      mkSystem = import ./lib/mksystem.nix specialArgs;
      mkStandalone = import ./lib/mkstandalone.nix specialArgs;
    in
    {
      nixosConfigurations.nixvidia = mkSystem "nixvidia" {
        system = "x86_64-linux";
        user = "bjarne";
      };

      nixosConfigurations.nixwsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "dev";
      };

      homeConfigurations.dev = mkStandalone {
        user = "dev";
      };
    };
}
