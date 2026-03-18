{
  configRoot,
  nixpkgs,
  overlays,
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
    overlays = overlays;
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
