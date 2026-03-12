{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:title = 'World of Warcraft' border_size 0 float off"
      "match:class feh float on"
      "match:class = steam_app_default match:float 1 float off"
    ];

    layerrule = [
      "blur on, match:namespace waybar"
      "blur_popups on, match:namespace waybar"
      "ignore_alpha 0, match:namespace waybar"
    ];

    workspace = [
      "special,gapsin:24,gapsout:64"
    ];
  };
}
