{
  pkgs,
  isWsl ? false,
  ...
}:

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
    ../fzf.nix
    ../zsh.nix
    ../nvim
    ../tmux
    ../lazygit.nix
    ../direnv.nix
    ../ranger.nix
  ];

  home.stateVersion = "26.05";
}
