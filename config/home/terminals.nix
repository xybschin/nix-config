{ ... }:
{
  config.my.features.home.terminals = { pkgs, ... }: {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
      enableZshIntegration = true;
      settings = {
        window-decoration = "server";
        macos-titlebar-style = "hidden";
        window-padding-x = 4;
        window-padding-y = 4;
        confirm-close-surface = false;
        bell-features = "no-attention,no-title,no-system,no-border";
        keybind = "ctrl+enter=unbind";
      };
    };

    programs.kitty = {
      enable = true;
    };
  };
}
