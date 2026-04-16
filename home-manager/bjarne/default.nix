{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
    google-chrome
    zathura
  ];

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
  ];
}
