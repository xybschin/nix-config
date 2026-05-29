{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/coding-agents
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
    python3
    nodejs
  ];
}
