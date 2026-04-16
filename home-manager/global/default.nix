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
    git
    systemctl-tui
    tree
    unzip
    gnumake
    gh
    jq
    htop
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
