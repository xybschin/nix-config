{ ... }:
{
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
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    OZONE_PLATFORM = "wayland";

    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    MOZ_ENABLE_WAYLAND = "1";

    QT_QPA_PLATFORMTHEME = "qt5ct";

    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    __GL_GSYNC_ALLOWED = "0";
    __GL_SYNC_TO_VBLANK = "0";

    PROTON_ENABLE_WAYLAND = "1";
  };

  imports = [
    ../../modules/home-manager/desktop
    ../../modules/home-manager/desktop/ghostty.nix
    ../../modules/home-manager/desktop/waybar.nix
    ../../modules/home-manager/desktop/font.nix
    ../../modules/home-manager/desktop/cursor.nix
    ../../modules/home-manager/desktop/zen-browser.nix
    ../../modules/home-manager/desktop/rofi
  ];
}
