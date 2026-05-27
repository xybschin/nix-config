{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/claude
    ../../modules/home-manager/copilot
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
    python3
    nodejs
  ];
}
