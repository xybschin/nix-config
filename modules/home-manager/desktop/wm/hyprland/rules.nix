{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class feh float on"
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
