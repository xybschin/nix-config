{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/claude
    ../../modules/home-manager/github-copilot.nix
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
  ];
}
