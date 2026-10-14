{
  config,
  configRoot,
  pkgs,
  ...
}:

let
  rofiConfigDir = "${configRoot}/config/shared/_desktop/rofi/config";
  iconsDir = "${configRoot}/config/shared/_desktop/rofi/icons";
  iconsLinkDir = "${config.xdg.dataHome}/rofi/monitor-icons";

  entries = pkgs.writeShellScript "rofi-monitor-menu-entries" ''
    run() { hyprctl dispatch "hl.dsp.exec_cmd(\"$1\")" >/dev/null 2>&1; }

    if [ -z "$1" ]; then
        printf '%s\0icon\x1f%s\n' \
            'profile1' '${iconsLinkDir}/monitor-dual.svg' \
            'profile2' '${iconsLinkDir}/monitor-single-left.svg' \
            'profile3' '${iconsLinkDir}/monitor-single-right.svg' \
            'profile4' '${iconsLinkDir}/monitor-ultrawide.svg'
    else
        case "$1" in
            profile1|profile2|profile3|profile4)
                run "${config.xdg.configHome}/hypr/scripts/monitor-config $1"
                ;;
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

    "rofi/monitor-icons/monitor-dual.svg".source =
      config.lib.file.mkOutOfStoreSymlink "${iconsDir}/monitor-dual.svg";
    "rofi/monitor-icons/monitor-single-left.svg".source =
      config.lib.file.mkOutOfStoreSymlink "${iconsDir}/monitor-single-left.svg";
    "rofi/monitor-icons/monitor-single-right.svg".source =
      config.lib.file.mkOutOfStoreSymlink "${iconsDir}/monitor-single-right.svg";
    "rofi/monitor-icons/monitor-ultrawide.svg".source =
      config.lib.file.mkOutOfStoreSymlink "${iconsDir}/monitor-ultrawide.svg";
  };

  home.packages = [ monitorMenu ];
}
