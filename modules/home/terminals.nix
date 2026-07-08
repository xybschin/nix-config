{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      window-decoration = "server";
      macos-titlebar-style = "hidden";
      window-padding-x = 6;
      window-padding-y = 6;
      confirm-close-surface = false;
      bell-features = "no-attention,no-title,no-system,no-border";
    };
  };

  programs.kitty = {
    enable = true;
  };
}
