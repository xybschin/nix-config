{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    devenv
    ducker
    htop
  ];
}
