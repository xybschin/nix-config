{ user, ... }:
{
  imports = [ ./shared ];
  home.username = user;
  home.homeDirectory = "/home/${user}";
  programs.home-manager.enable = true;
}
