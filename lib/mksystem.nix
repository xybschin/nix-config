{
  home-manager,
  inputs,
  nixos-wsl,
  nixpkgs,
  overlays,
  configRoot,
  lib,
  ...
}:

host: user:
{ system, ... }:

let
  isWsl = nixpkgs.lib.strings.hasInfix "wsl" host;

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
in
nixpkgs.lib.nixosSystem rec {
  inherit system specialArgs;

  modules = [
    hostConfig
    userSystemConfig
    { nixpkgs.overlays = overlays; }
    (if isWsl then nixos-wsl.nixosModules.wsl else { })
    home-manager.nixosModules.home-manager
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
  ];
}
