{
  nixpkgs,
  overlays,
  inputs,
  configRoot,
  ...
}:

name:
{
  system,
  user,
}:

let
  isWsl = nixpkgs.lib.strings.hasInfix "wsl" name;

  hostConfig = ../hosts/${if isWsl then "wsl" else name};

  userSystemConfig = ../hosts/users/${user};
  userHomeConfig = import ../home-manager/${user};

  specialArgs = {
    inherit
      isWsl
      configRoot
      user
      inputs
      ;
  };
in
nixpkgs.lib.nixosSystem rec {
  inherit system specialArgs;

  modules = [
    hostConfig
    userSystemConfig

    { nixpkgs.config.allowUnfree = true; }
    { nixpkgs.overlays = overlays; }

    (if isWsl then inputs.nixos-wsl.nixosModules.wsl else { })

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.${user} = userHomeConfig;
    }
  ];
}
