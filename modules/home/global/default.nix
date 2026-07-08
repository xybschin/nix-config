{
  pkgs,
  lib,
  isWsl ? false,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
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
    ../../../modules/home/fzf.nix
    ../../../modules/home/zsh.nix
    ../../../modules/home/nvim
    ../../../modules/home/tmux
    ../../../modules/home/lazygit.nix
    ../../../modules/home/direnv.nix
    ../../../modules/home/ranger.nix
  ] ++ (
    if isWsl then [ ../../../modules/home/1password-wsl.nix ]
    else if isDarwin then [ ../../../modules/home/1password-darwin.nix ]
    else [ ../../../modules/home/1password-native.nix ]
  );

  home.stateVersion = "26.05";
}
