{ ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "~/wallpapers/single/artemis-ii-earth.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };

  home.file.wallpapers.source = ./wallpapers;
}
