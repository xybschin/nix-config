{
  pkgs,
  user,
  ...
}:
{
  imports = [ ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = user;
  };

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [
        "root"
        user
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  networking.hostName = "nixwsl";
  virtualisation.docker.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
