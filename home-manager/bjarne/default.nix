{
  overlays,
  ...
}:
{
  home.stateVersion = "25.05";

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

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    PROTON_ENABLE_WAYLAND = "1";
    PROTON_USE_WINED3D = "1";
    GSK_RENDERER = "gl";
  };

  imports = [
    ../../modules/home-manager/desktop
    ../../modules/home-manager/shell/fzf.nix
    ../../modules/home-manager/shell/zsh.nix
    ../../modules/home-manager/cli/nvim
    ../../modules/home-manager/cli/tmux
    ../../modules/home-manager/cli/lazygit.nix
    ../../modules/home-manager/cli/direnv.nix
    ../../modules/home-manager/cli/ranger.nix
    ../../modules/home-manager/cli/opencode.nix
    ../../modules/home-manager/1password.nix
  ];
}
