{
  overlays,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = overlays;
  };

  home.packages = with pkgs; [
    htop
    ducker
    tree
    unzip
    gnumake
    git
    devenv
  ];

  imports = [
    ../../modules/home-manager/shell/fzf.nix
    ../../modules/home-manager/shell/zsh.nix
    ../../modules/home-manager/cli/nvim
    ../../modules/home-manager/cli/tmux
    ../../modules/home-manager/cli/lazygit.nix
    ../../modules/home-manager/cli/direnv.nix
    ../../modules/home-manager/cli/ranger.nix
    ../../modules/home-manager/cli/opencode.nix
    ../../modules/home-manager/1password.nix
  ];

  home.stateVersion = "25.05";
}
