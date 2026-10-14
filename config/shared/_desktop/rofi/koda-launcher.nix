{
  config,
  configRoot,
  pkgs,
  ...
}:

let
  rofiConfigDir = "${configRoot}/config/shared/_desktop/rofi/config";
  # Glyphs in MonitorIcons.ttf (PUA-A): dual, single-left, single-right, ultrawide.
  glyphDual = "\\U000F5000";
  glyphSingleLeft = "\\U000F5001";
  glyphSingleRight = "\\U000F5002";
  glyphUltrawide = "\\U000F5003";

  monitorIconsFont = pkgs.runCommand "monitor-icons-font" { } ''
    install -Dm644 ${./fonts/MonitorIcons.ttf} \
      $out/share/fonts/truetype/MonitorIcons.ttf
  '';

  entries = pkgs.writeShellScript "rofi-monitor-menu-entries" ''
    run() { hyprctl dispatch "hl.dsp.exec_cmd(\"$1\")" >/dev/null 2>&1; }

    if [ -z "$1" ]; then
        printf '%b\n' \
            '${glyphDual}' \
            '${glyphSingleLeft}' \
            '${glyphSingleRight}' \
            '${glyphUltrawide}'
    else
        case "$1" in
            $'${glyphDual}') run "${config.xdg.configHome}/hypr/scripts/monitor-config profile1" ;;
            $'${glyphSingleLeft}') run "${config.xdg.configHome}/hypr/scripts/monitor-config profile2" ;;
            $'${glyphSingleRight}') run "${config.xdg.configHome}/hypr/scripts/monitor-config profile3" ;;
            $'${glyphUltrawide}') run "${config.xdg.configHome}/hypr/scripts/monitor-config profile4" ;;
            *) exit 0 ;;
        esac
    fi
  '';

  monitorMenu = pkgs.writeShellApplication {
    name = "rofi-monitor-menu";
    runtimeInputs = [ pkgs.rofi ];
    text = ''
      rofi \
        -modes "monitor:${entries}" \
        -show monitor \
        -theme koda-monitor \
        -no-custom
    '';
  };
in
{
  xdg.dataFile = {
    "rofi/themes/koda-launcher.rasi".source =
      config.lib.file.mkOutOfStoreSymlink "${rofiConfigDir}/koda-launcher.rasi";
    "rofi/themes/koda-monitor.rasi".source =
      config.lib.file.mkOutOfStoreSymlink "${rofiConfigDir}/koda-monitor.rasi";
  };

  home.packages = [
    monitorMenu
    monitorIconsFont
  ];
}
