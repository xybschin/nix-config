{
  config,
  configRoot,
  pkgs,
  lib,
  ...
}:
let
  quickshellDir = "${configRoot}/config/shared/_desktop/quickshell/config";

  c = config.lib.stylix.colors;
  # QML reads colours as #AARRGGBB.
  argb = hex: alpha: "#${alpha}${hex}";

  theme = {
    colors = {
      bg = argb c.base00 "B5";
      border = argb c.base01 "88";
      fg = argb c.base08 "FF";
      fgDim = argb c.base04 "FF";
      highlight = argb c.base05 "11";
      accent = argb c.base06 "FF";
    };
    font = {
      family = config.stylix.fonts.monospace.name;
      size = 12;
      tileFamily = "JetBrainsMono Nerd Font";
      tileSize = 18;
    };
    terminal = "ghostty";
  };
in
{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink quickshellDir;
  xdg.configFile."koda/theme.json".text = builtins.toJSON theme;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "quickshell";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.quickshell;
      Environment = [ "QS_ICON_THEME=${config.stylix.icons.dark}" ];
      Restart = "always";
      RestartSec = "10";
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
