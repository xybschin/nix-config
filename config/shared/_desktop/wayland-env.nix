{ ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";

    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    OZONE_PLATFORM = "wayland";

    MOZ_ENABLE_WAYLAND = "1";

    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
