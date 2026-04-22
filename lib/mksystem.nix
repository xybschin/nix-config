{
  home-manager,
  inputs,
  nixos-wsl,
  nix-darwin,
  nixpkgs,
  overlays,
  configRoot,
  lib,
  ...
}:

host: user:
{ system, ... }:

let
  isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
  isWsl = !isDarwin && nixpkgs.lib.strings.hasInfix "wsl" host;

  hostConfig = ../hosts/${if isWsl then "wsl" else host};
  userSystemConfig = ../hosts/users/${user};

  hmGlobalPath = ../home-manager/global;
  hmUserPath = ../home-manager/${user};
  hmHostPath = ../home-manager/${user}/${host};

  hmGlobal = import hmGlobalPath;
  hmUser = import hmUserPath;

  specialArgs = {
    inherit
      isWsl
      configRoot
      user
      home-manager
      nixos-wsl
      inputs
      overlays
      host
      ;
  };

  mkSystemFn = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  hmModule = if isDarwin then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager;
in
mkSystemFn rec {
  inherit system specialArgs;

  modules = [
    hostConfig
    { nixpkgs.overlays = overlays; }
    hmModule
    {
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.${user} = {
        imports = [
          hmGlobal
          hmUser
        ]
        ++ (lib.optional (builtins.pathExists hmHostPath) (import hmHostPath));
      };
    }
  ]
  ++ (lib.optionals (!isDarwin) [
    userSystemConfig
    { networking.hostName = host; }
    (if isWsl then nixos-wsl.nixosModules.wsl else { })
  ]);
}
