{
  pkgs,
  ...
}:

let
  entries = pkgs.writeShellScript "rofi-powermenu-entries" ''
    shutdown='󰐥'
    reboot='󰜉'
    lock='󰌾'
    logout='󰍃'

    run() { hyprctl dispatch "hl.dsp.exec_cmd(\"$1\")" >/dev/null 2>&1; }

    if [ -z "$1" ]; then
        printf '%s\0Shutdown\n%s\0Reboot\n%s\0Lock screen\n%s\0Log out\n%s\0Cancel\n' \
            "$shutdown" "$reboot" "$lock" "$logout"
    else
        case "$1" in
            "$shutdown") run "hyprshutdown -t 'Shutting down...' --post-cmd 'systemctl poweroff'" ;;
            "$reboot")   run "hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot'" ;;
            "$lock")     run hyprlock ;;
            "$logout")   run "hyprshutdown" ;;
            *)           exit 0 ;;
        esac
    fi
  '';
  powermenu = pkgs.writeShellApplication {
    name = "rofi-powermenu";
    runtimeInputs = [ pkgs.rofi ];
    text = ''
      rofi \
        -modes "powermenu:${entries}" \
        -show powermenu \
        -theme koda-tiles \
        -no-custom
    '';
  };
in
{
  home.packages = [ powermenu ];
}
