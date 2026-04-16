{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/claude-code.nix
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
  ];
}
