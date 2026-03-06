{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    fzf
  ];

  imports = [
    ./fzf.nix
    ./zsh.nix
  ];
}
