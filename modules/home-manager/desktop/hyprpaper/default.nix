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
          fit_mode = "contain";
        }
        {
          monitor = "HDMI-A-1";
          path = "~/wallpapers/right.jpg";
          fit_mode = "contain";
        }
        {
          monitor = "";
          path = "~/wallpapers/left.jpg";
          fit_mode = "contain";
        }
      ];
    };
  };

  home.file.wallpapers.source = ./wallpapers;
}
