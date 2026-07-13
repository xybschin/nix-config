{
  config,
  pkgs,
  lib,
  ...
}:

let
  c = config.lib.stylix.colors;
  rgba = hex: "${hex}ff";
in
{
  programs.fuzzel = {
    enable = true;
    package = pkgs.fuzzel;
    settings = {
      main = {
        font = "${config.stylix.fonts.monospace.name}:size=10";
        dpi-aware = "no";
        icons-enabled = false;
        placeholder = "search...";
        prompt = "> ";
        layer = "overlay";
        anchor = "top";
        width = 30;
        lines = 15;
      };
      colors = {
        background = rgba c.base00;
        text = rgba c.base05;
        match = rgba c.base0D;
        selection = rgba c.base01;
        selection-text = rgba c.base05;
        selection-match = rgba c.base0D;
        border = rgba c.base0D;
        prompt = rgba c.base04;
        input = rgba c.base05;
        placeholder = rgba c.base03;
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
}
