{
  nixpkgs,
  overlays,
  inputs,
  configRoot,
  ...
}:
{
  user,
}:
let
  userConfig = ../home-manager/${user}/standalone.nix;
  specialArgs = {
    isWsl = true;
    configRoot = configRoot;
    user = user;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = overlays;
  };
  extraSpecialArgs = specialArgs;
  modules = [ userConfig ];
}
