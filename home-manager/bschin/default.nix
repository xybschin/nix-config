{ pkgs, isWsl, ... }:
{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Bjarne Schindler";
      user.email = "bjarne.schindler@adesso.de";
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
  ]
  ++ (
    if isWsl then
      [
        ../../modules/home-manager/cli/optional/1password-bridge.nix
      ]
    else
      [ ]
  );
}
