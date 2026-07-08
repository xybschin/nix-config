{ ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        # 5 min idle: lock screen
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        # 5 min idle: turn off display
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # 30 min idle: hibernate
        {
          timeout = 1800;
          on-timeout = "systemctl hibernate";
        }
      ];
    };
  };
}
