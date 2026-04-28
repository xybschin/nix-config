{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/claude-code.nix
    ../../modules/home-manager/github-copilot.nix
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
  ];
}
