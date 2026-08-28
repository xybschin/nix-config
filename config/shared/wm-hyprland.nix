{ ... }:
{
  config.my.features.home."shared.desktop.wm.hyprland" =
    {
      config,
      configRoot,
      pkgs,
      lib,
      ...
    }:
    let
      hyprDir = "${configRoot}/config/shared/_desktop/wm/hyprland/config";
      scriptsDir = "${configRoot}/config/shared/_desktop/wm/hyprland/scripts";
    in
    {
      imports = [
        ./_desktop/hyprpaper
        ./_desktop/quickshell
        ./_desktop/wm/hyprland/hyprlock.nix
      ];

      home.packages = with pkgs; [
        socat
        jq
        hyprcursor
        hyprshot
        hyprshutdown
        hyprpicker
      ];

      # Don't use home-manager's hyprland module config generation
      # We provide our own Lua config files instead
      # Hyprland is launched via systemd service from NixOS system config

      xdg.configFile."hypr/hyprland.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${hyprDir}/hyprland.lua";
      xdg.configFile."hypr/env.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/env.lua";
      xdg.configFile."hypr/settings.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${hyprDir}/settings.lua";
      xdg.configFile."hypr/binds.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/binds.lua";
      xdg.configFile."hypr/rules.lua".source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/rules.lua";

      xdg.configFile."hypr/scripts/rofi-launch".source =
        config.lib.file.mkOutOfStoreSymlink "${scriptsDir}/rofi-launch";

      # Generated from stylix palette
      xdg.configFile."hypr/colors.lua".text =
        let
          c = config.lib.stylix.colors.withHashtag;
          rgb = color: "rgb(${lib.removePrefix "#" color})";
        in
        ''
          local M = {}
          M.base00 = "${rgb c.base00}"
          M.base01 = "${rgb c.base01}"
          M.base02 = "${rgb c.base02}"
          M.base03 = "${rgb c.base03}"
          M.base04 = "${rgb c.base04}"
          M.base05 = "${rgb c.base05}"
          M.base06 = "${rgb c.base06}"
          M.base07 = "${rgb c.base07}"
          M.base08 = "${rgb c.base08}"
          M.base09 = "${rgb c.base09}"
          M.base0A = "${rgb c.base0A}"
          M.base0B = "${rgb c.base0B}"
          M.base0C = "${rgb c.base0C}"
          M.base0D = "${rgb c.base0D}"
          M.base0E = "${rgb c.base0E}"
          M.base0F = "${rgb c.base0F}"
          return M
        '';

      services.hyprpolkitagent.enable = true;
    };
}
