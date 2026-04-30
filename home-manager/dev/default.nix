{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager/claude
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
  ];
}
