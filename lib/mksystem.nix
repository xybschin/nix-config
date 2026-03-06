{
  nixpkgs,
  overlays,
  inputs,
  configRoot,
}:

name:
{
  system,
  user,
}:

let
  isWsl = nixpkgs.lib.strings.hasInfix "wsl" name;
  hostConfig = ../hosts/${
    if isWsl then "wsl/${nixpkgs.lib.strings.removePrefix "wsl:" name}" else name
  };

  userSystemConfig = ../hosts/users/${user};

  specialArgs = {
    isWsl = isWsl;
    configRoot = configRoot;
    user = user;
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
      home-manager.users.${user} = import ../home-manager/${user};
    }
  ];
}
