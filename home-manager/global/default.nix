{
  overlays,
  pkgs,
  lib,
  isWsl ? false,
  isDarwin ? false,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = overlays;
  };

  home.packages =
    with pkgs;
    [
      git
      tree
      unzip
      gnumake
      gh
      jq
      htop
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.systemctl-tui
    ];

  imports = [
    ../../modules/home-manager/fzf.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/nvim
    ../../modules/home-manager/tmux
    ../../modules/home-manager/lazygit.nix
    ../../modules/home-manager/direnv.nix
    ../../modules/home-manager/ranger.nix
  ] ++ (
    if isWsl then [ ../../modules/home-manager/1password-wsl.nix ]
    else if isDarwin then [ ../../../modules/darwin/1password.nix ]
    else [ ../../modules/home-manager/1password-native.nix ]
  );

  home.stateVersion = "26.05";
}
