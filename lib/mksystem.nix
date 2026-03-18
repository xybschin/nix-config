{
  home-manager,
  inputs,
  nixos-wsl,
  nixpkgs,
  overlays,
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
      home-manager
      nixos-wsl
      inputs
      overlays
      ;
  };
in
nixpkgs.lib.nixosSystem rec {
  inherit system specialArgs;

  modules = [
    hostConfig
    userSystemConfig
    inputs.nixos-plymouth.nixosModules.default

    { nixpkgs.overlays = overlays; }

    (if isWsl then nixos-wsl.nixosModules.wsl else { })

    home-manager.nixosModules.home-manager
    {
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.${user} = userHomeConfig;
    }
  ];
}
