{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      vscode
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.google-chrome
      pkgs.zathura
    ];

  imports = [
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/kitty.nix
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

}
