{
  configRoot,
  nixpkgs,
  overlays,
  home-manager,
  inputs,
  lib,
  ...
}:
{
  user,
}:
let
  hmGlobalPath = ../home-manager/global;
  hmUserPath = ../home-manager/${user};
  hmHostPath = ../home-manager/${user}/nixwsl;

  specialArgs = {
    inherit
      user
      configRoot
      overlays
      inputs
      ;
    isWsl = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = overlays;
  };
  extraSpecialArgs = specialArgs;
  modules = [
    {
      home.username = user;
      home.homeDirectory = "/home/${user}";
      programs.home-manager.enable = true;
      imports = [
        hmGlobalPath
        hmUserPath
        hmHostPath
      ];
    }
  ];
}
