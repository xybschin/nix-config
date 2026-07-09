{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/home/coding-agents
  ];

  # Stylix is auto-enabled by the NixOS module; satisfy the base16Scheme/image
  # assertion without pulling in the full desktop stylix config (wallpaper,
  # cursor themes, hyprpaper target) which needs a graphical session.
  stylix.base16Scheme = ../../../modules/shared/stylix/koda-dark.yaml;

  home.packages = with pkgs; [
    home-manager
    devenv
    ducker
    htop
    python3
    nodejs
    bun
  ];

  home.sessionPath = [ "$HOME/.bun/bin" ];

  home.sessionVariables = {
    NODE_USE_SYSTEM_CA = "1";
  };
}
