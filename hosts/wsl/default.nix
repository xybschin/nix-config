{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nixos/common.nix
    inputs.vscode-server.nixosModules.default
  ];

  services.vscode-server.enable = true;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = user;
    interop.register = true;
  };

  services.logind.enable = true;
  virtualisation.docker.enable = true;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    (azure-cli.withExtensions [ azure-cli.extensions.azure-devops ])
  ];

  users.users."${user}" = {
    linger = true;
  };
}
