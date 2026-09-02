{ ... }:
{
  config.my.features.home."shared.stylix" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      stylix = {
        enable = true;

        base16Scheme = ./_stylix/koda-dark.yaml;
        polarity = "dark";
        overlays.enable = false;

        icons = {
          enable = true;
          package = pkgs.whitesur-icon-theme;
          light = "WhiteSur";
          dark = "WhiteSur";
        };

        image = ./_desktop/hyprpaper/wallpapers/single/nix-wallpaper-nineish-dark-gray.png;
        imageScalingMode = "fill";

        cursor = {
          name = "macOS";
          package = pkgs.apple-cursor;
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
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font Mono";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            terminal = 12;
            applications = 12;
            desktop = 12;
            popups = 12;
          };
        };

        targets = {
          hyprland.enable = false;
          # Wallpaper config is managed manually in ~/.config/hypr/hyprpaper.conf
          hyprpaper.enable = false;
        };
      };

      home.pointerCursor.enable = lib.mkIf config.stylix.enable true;
    };
}
