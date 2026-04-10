{ scripts, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [ ];

    exec = [
      "sleep 3; uwsm-app -- 1password --silent"
      "${scripts}/auto-hide-wine-trays"
      "${scripts}/monitor-config"
    ];

    exec-once = [
      "sleep 3; uwsm-app -- 1password --silent"
      "${scripts}/auto-hide-wine-trays"
      "${scripts}/monitor-config"
    ];

    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 1;
      "col.active_border" = "rgb(b0b0b0)";
      "col.inactive_border" = "rgb(272727)";
      resize_on_border = true;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding_power = 0;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      rounding = 0;

      blur = {
        enabled = true;
        size = 8;
        passes = 3;
        vibrancy = 0.15;
      };

      shadow.enabled = false;
    };

    animations.enabled = false;
    debug.disable_logs = false;

    input = {
      kb_layout = "eu";
      follow_mouse = 2;
      accel_profile = "custom 0.03544952611394753 0.000 0.009 0.019 0.028 0.038 0.047 0.056 0.066 0.075 0.085 0.094 0.104 0.118 0.132 0.146 0.161 0.175 0.189 0.203 0.217 0.231 0.246 0.260 0.274 0.288 0.302 0.316 0.330 0.345 0.359 0.373 0.387 0.403 0.425 0.446 0.468 0.489 0.511 0.532 0.554 0.575 0.597 0.618 0.640 0.661 0.683 0.704 0.726 0.747 0.769 0.790 0.812 0.833 0.855 0.876 0.898 0.919 0.941 0.962 0.984 1.005 1.027 1.048 1.070 1.091 1.113 1.134 1.156 1.177 1.199 1.220 1.242 1.263 1.285 1.306 1.328 1.349 1.371 1.392 1.414 1.435 1.457 1.478 1.500 1.521 1.543 1.564 1.586 1.607 1.629 1.650 1.672 1.693 1.715 1.737 1.758 1.780 1.801 1.823 1.867";
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      force_split = 2;
      split_width_multiplier = 1.5;
    };

    misc = {
      force_default_wallpaper = -1;
      exit_window_retains_fullscreen = true;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
  };
}
