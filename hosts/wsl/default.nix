{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../modules/nixos/common.nix
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = user;
  };

  virtualisation.docker.enable = true;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    (azure-cli.withExtensions [ azure-cli.extensions.azure-devops ])
  ];
}
