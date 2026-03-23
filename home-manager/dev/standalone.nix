{ user, ... }:
{
  imports = [ ./shared.nix ];
  home.username = user;
  home.homeDirectory = "/home/${user}";
  programs.home-manager.enable = true;
}
