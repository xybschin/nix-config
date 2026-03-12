{ pkgs, isWsl, ... }:
{
  home.packages = with pkgs; [
    htop
    ducker
    tree
    unzip
    gnumake
    git
  ];

  imports = [
    ../../modules/home-manager/shell
    ../../modules/home-manager/cli
    ../../modules/home-manager/cli/optional/opencode.nix
  ]
  ++ (
    if isWsl then
      [
        ../../modules/home-manager/cli/optional/1password-bridge.nix
      ]
    else
      [
        ../../modules/home-manager/cli/optional/1password-ssh.nix
      ]
  );

  home.stateVersion = "25.05";
}
