{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/home/coding-agents
  ];

  # Enable stylix's CLI targets (fzf, bat, btop, zsh, ...) for this headless
  # WSL host. We intentionally do NOT import modules/shared/stylix here: that
  # module pulls in cursor themes, wallpaper, and hyprpaper targets that require
  # a graphical session and would set XCURSOR_* env vars / install bibata-cursors
  # pointlessly on WSL. base16Scheme is set so the option default doesn't throw.
  stylix = {
    enable = true;
    base16Scheme = ../../../modules/shared/stylix/koda-dark.yaml;
  };

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
