{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
      overlays = [ inputs.neovim-nightly-overlay.overlays.default ];

      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          inputs
          configRoot
          ;
      };
    in
    {
      nixosConfigurations.adesnix = mkSystem "wsl:adesnix" {
        system = "x86_64-linux";
        user = "xybschin";
      };

      nixosConfigurations.nixvidia = mkSystem "nixvidia" {
        system = "x86_64-linux";
        user = "xybschin";
      };
    };
}
