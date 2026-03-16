{ ... }:
{
  home.stateVersion = "25.05";

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

  imports = [
    ../../modules/home-manager/desktop
    ../../modules/home-manager/shell
    ../../modules/home-manager/cli
    ../../modules/home-manager/cli/ranger.nix
    ../../modules/home-manager/cli/optional/opencode.nix
    ../../modules/home-manager/cli/optional/1password-ssh.nix
  ];
}
