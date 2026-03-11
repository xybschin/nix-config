{ pkgs, isWsl, ... }:
{
  imports = [ ../common ];
  home.username = "xybschin";
  home.homeDirectory = "/home/xybschin";
  programs.home-manager.enable = true;
}
