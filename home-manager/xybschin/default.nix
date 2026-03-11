{ pkgs, isWsl, ... }:
{
  imports = [ ../common];
  programs.home-manager.enable = true;
}
