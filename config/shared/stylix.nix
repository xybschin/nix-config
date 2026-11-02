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

        # base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";
        base16Scheme = ./_stylix/koda-dark.yaml;
        polarity = "dark";
        overlays.enable = false;

        icons = {
          enable = true;
          package = pkgs.whitesur-icon-theme;
          light = "WhiteSur";
          dark = "WhiteSur";
        };


        cursor = {
          name = "macOS";
          package = pkgs.apple-cursor;
          size = 24;
        };

        fonts = {
          sansSerif = {
            package = pkgs.segoe-ui;
            name = "Segoe-UI";
          };
          serif = {
            package = pkgs.segoe-ui;
            name = "Segoe-UI";
          };
          monospace = {
            package = pkgs.nerd-fonts.iosevka;
            name = "Iosevka Nerd Font Mono";
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
      };

      home.pointerCursor.enable = lib.mkIf config.stylix.enable true;
    };
}
