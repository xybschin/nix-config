{
  pkgs,
  overlays,
  ...
}:
{
  home.stateVersion = "26.05";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = overlays;
  };

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

  home.packages = [
    pkgs.systemctl-tui
  ];

  home.sessionVariables = {
    EDITOR = "nvim";

    # Wayland core
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    OZONE_PLATFORM = "wayland";

    # Electron apps
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    # Mozilla
    MOZ_ENABLE_WAYLAND = "1";

    # Qt
    QT_QPA_PLATFORMTHEME = "qt5ct";

    # Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    __GL_GSYNC_ALLOWED = "0";
    __GL_SYNC_TO_VBLANK = "0";

    # Proton/Gaming
    PROTON_ENABLE_WAYLAND = "1";
  };

  imports = [
    ../../modules/home-manager/fzf.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/nvim
    ../../modules/home-manager/tmux
    ../../modules/home-manager/lazygit.nix
    ../../modules/home-manager/direnv.nix
    ../../modules/home-manager/ranger.nix
    ../../modules/home-manager/opencode
    ../../modules/home-manager/1password.nix

    ../../modules/home-manager/desktop
    ../../modules/home-manager/desktop/wm/hyprland
    ../../modules/home-manager/desktop/ghostty.nix
    ../../modules/home-manager/desktop/waybar.nix
    ../../modules/home-manager/desktop/font.nix
    ../../modules/home-manager/desktop/cursor.nix
    ../../modules/home-manager/desktop/zen-browser.nix
    ../../modules/home-manager/desktop/rofi
  ];
}
