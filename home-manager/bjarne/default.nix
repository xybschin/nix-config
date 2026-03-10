{ pkgs, ... }:
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

  home.packages = with pkgs; [
    htop
    ducker
    tree
    unzip
    fastfetch
    gnumake
  ];

  imports = [
    ../../modules/home-manager/shell
    ../../modules/home-manager/cli
    ../../modules/home-manager/cli/optional/opencode.nix
  ];
}
