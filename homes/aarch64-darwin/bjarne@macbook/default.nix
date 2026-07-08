{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/home/ghostty.nix
    ../../../modules/home/kitty.nix
    ../../../modules/home/coding-agents
  ];

  home.packages =
    with pkgs;
    [
      obsidian
      python3
      nodejs
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
