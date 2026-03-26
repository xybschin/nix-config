{
  configRoot,
  nixpkgs,
  overlays,
  home-manager,
  inputs,
  ...
}:
{
  user,
}:
let
  userConfig = ../home-manager/${user}/standalone.nix;
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
  modules = [ userConfig ];
}
