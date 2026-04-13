{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/wallpapers/left.jpg"
        "~/wallpapers/right.jpg"
      ];
      splash = false;
      wallpaper = [
        {
          monitor = "DP-1";
          path = "~/wallpapers/left.jpg";
        }
        {
          monitor = "HDMI-A-1";
          path = "~/wallpapers/right.jpg";
        }
        {
          monitor = "Virtual-1";
          path = "~/wallpapers/left.jpg";
        }
      ];
    };
  };

  home.file.wallpapers.source = ./wallpapers;
}
