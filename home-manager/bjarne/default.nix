{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      vscode
      obsidian
      python3
      nodejs
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.google-chrome
      pkgs.zathura
    ];

  imports = [
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/kitty.nix
    ../../modules/home-manager/claude
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
