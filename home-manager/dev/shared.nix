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
    systemctl-tui
  ];

  imports = [
    ../../modules/home-manager/fzf.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/nvim
    ../../modules/home-manager/tmux
    ../../modules/home-manager/lazygit.nix
    ../../modules/home-manager/direnv.nix
    ../../modules/home-manager/ranger.nix
    ../../modules/home-manager/opencode
    ../../modules/home-manager/1password.nix
  ];

  home.stateVersion = "26.05";
}
