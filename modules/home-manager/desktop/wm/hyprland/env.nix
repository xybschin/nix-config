{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    env = [
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "QT_QPA_PLATFORM,wayland"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      "HYPRSHOT_DIR,screenshots"
      "NIXOS_OZONE_WL,1"
      "WLR_NO_HARDWARE_CURSORS,1"
    ];
  };
}
