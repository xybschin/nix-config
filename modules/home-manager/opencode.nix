{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [ opencode ];
  home.shellAliases.oc = "opencode";

  programs.opencode = {
    enable = true;
    settings = lib.mkMerge [
      (lib.mkIf (builtins.pathExists "${config.xdg.configHome}/opencode/providers.json") {
        provider = builtins.fromJSON (builtins.readFile "${config.xdg.configHome}/opencode/providers.json");
      })
    ];
  };

  home.file.".config/opencode/themes/koda.json".text = builtins.toJSON {
    "\$schema" = "https://opencode.ai/theme.json";
    defs = {
      dark_bg = "#101010";
      dark_fg = "#b0b0b0";
      dark_line = "#272727";
      dark_highlight = "#458ee6";
      dark_info = "#8ebeec";
      dark_success = "#86cd82";
      dark_warning = "#d9ba73";
      dark_danger = "#ff7676";
      dark_muted = "#777777";

      light_bg = "#faf9f5";
      light_fg = "#101010";
      light_line = "#ebebeb";
      light_highlight = "#0A89FF";
      light_info = "#0253be";
      light_success = "#407f00";
      light_warning = "#b07700";
      light_danger = "#ca0043";
      light_muted = "#3d3d3d";
    };
    theme = {
      primary = {
        dark = "dark_highlight";
        light = "light_highlight";
      };
      background = {
        dark = "dark_bg";
        light = "light_bg";
      };
      backgroundPanel = {
        dark = "dark_line";
        light = "light_line";
      };
      backgroundElement = {
        dark = "#1e1e1e";
        light = "#ebebeb";
      };
      text = {
        dark = "dark_fg";
        light = "light_fg";
      };
      textMuted = {
        dark = "dark_muted";
        light = "light_muted";
      };
      error = {
        dark = "dark_danger";
        light = "light_danger";
      };
      warning = {
        dark = "dark_warning";
        light = "light_warning";
      };
      success = {
        dark = "dark_success";
        light = "light_success";
      };
      info = {
        dark = "dark_info";
        light = "light_info";
      };
    };
  };
}
