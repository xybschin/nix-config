{
  inputs,
  overlays,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = overlays;
  };

  programs.home-manager.enable = true;
  programs.ssh.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "xybschin";
      user.email = "hello@bjarneschindler.dev";
      extraConfig.credential.helper = "store";
      color.ui = true;
      init.defaultBranch = "main";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  imports = [
    ../../modules/home-manager/desktop
    ../../modules/home-manager/shell
    ../../modules/home-manager/cli/nvim
    ../../modules/home-manager/cli/tmux
    ../../modules/home-manager/cli/lazygit.nix
    ../../modules/home-manager/cli/direnv.nix
    ../../modules/home-manager/cli/ranger.nix
    ../../modules/home-manager/cli/optional/opencode.nix
    ../../modules/home-manager/cli/optional/1password-ssh.nix
  ];
}
