{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

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

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    waybar-audio-control = {
      url = "github:xybschin/waybar-audio-control";
    };

    rvm-webcam = {
      url = "github:xybschin/rvm-webcam";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall.namespace = "config";

      overlays = [
        inputs.claude-code.overlays.default
      ];

      systems.modules.nixos = [
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        {
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ];

      systems.modules.darwin = [
        inputs.home-manager.darwinModules.home-manager
        inputs.stylix.darwinModules.stylix
        {
          home-manager.extraSpecialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
        }
      ];

      systems.hosts.fenris.modules = [
        inputs.hyprland.nixosModules.default
      ];

      systems.hosts.nixvm.modules = [
        inputs.hyprland.nixosModules.default
      ];

      systems.hosts.nixwsl.modules = [
        inputs.nixos-wsl.nixosModules.wsl
        inputs.vscode-server.nixosModules.default
      ];

      # configRoot is passed to home-manager modules via extraSpecialArgs above.
      # The per-host specialArgs below pass it to NixOS system modules too.
      systems.hosts.fenris.specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      systems.hosts.nixvm.specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      systems.hosts.nixwsl.specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      systems.hosts.macbook.specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";

      # configRoot and isWsl for standalone home configurations
      homes.modules = [
        inputs.stylix.homeModules.stylix
      ];

      homes.users."moonz@fenris".specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      homes.users."bjarne@macbook".specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      homes.users."dev@nixvm".specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";
      homes.users."dev@nixwsl".specialArgs.configRoot = builtins.getEnv "CONFIG_ROOT";

      # WSL flag for the global home module (standalone and system-integrated)
      homes.users."dev@nixwsl".specialArgs.isWsl = true;
    };
}
