{
  config,
  lib,
  pkgs,
  ...
}:

{
  stylix = {
    enable = true;

    base16Scheme = ./koda-dark.yaml;
    polarity = "dark";

    image = ../desktop/hyprpaper/wallpapers/single/artemis-ii-earth.jpg;
    imageScalingMode = "fill";

    cursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    fonts = {
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.inter;
        name = "Inter";
      };
      monospace = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 12;
        applications = 10;
        desktop = 12;
        popups = 10;
      };
    };

    targets = {
      # Hyprland uses Lua config, not home-manager's hyprland module
      hyprland.enable = false;
      # Keep hyprpaper managed manually (wallpaper already set via stylix.image)
      hyprpaper.enable = true;
      zen-browser.profileNames = [ "*" ];
    };
  };

  # Fix deprecation warning from home-manager
  home.pointerCursor.enable = lib.mkIf config.stylix.enable true;
}
