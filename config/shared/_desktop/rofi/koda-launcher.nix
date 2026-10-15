{
  config,
  lib,
  pkgs,
  ...
}:

let
  monitorProfiles = config.my.rofi.monitorProfiles;

  # Emits one $'…' escaped glyph per profile (rendered by MonitorIcons.ttf).
  glyphArgs = lib.concatMapStringsSep " " (p: "$'${p.glyph}'") monitorProfiles;

  # One `case` arm per profile, matching the selected glyph to its profile.
  caseArms = lib.concatMapStrings (
    p: "        $'${p.glyph}') run \"${config.xdg.configHome}/hypr/scripts/monitor-config ${p.name}\" ;;\n"
  ) monitorProfiles;

  monitorIconsFont = pkgs.runCommand "monitor-icons-font" { } ''
    install -Dm644 ${./fonts/MonitorIcons.ttf} \
      $out/share/fonts/truetype/MonitorIcons.ttf
  '';

  entries = pkgs.writeShellScript "rofi-monitor-menu-entries" ''
    run() { hyprctl dispatch "hl.dsp.exec_cmd(\"$1\")" >/dev/null 2>&1; }

    if [ -z "$1" ]; then
        for g in ${glyphArgs}; do
            printf '%s\n' "$g"
        done
    else
        case "$1" in
    ${caseArms}        *) exit 0 ;;
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
        -theme koda-tiles \
        -no-custom
    '';
  };
in
{
  options.my.rofi.monitorProfiles = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Profile name passed to hypr/scripts/monitor-config.";
        };
        glyph = lib.mkOption {
          type = lib.types.str;
          description = "bash $'…' escaped glyph rendered by the MonitorIcons font.";
        };
      };
    });
    default = [ ];
    description = "Monitor layout profiles exposed by the rofi monitor menu.";
  };

  config = {
    home.packages = lib.mkIf (monitorProfiles != [ ]) [
      monitorMenu
      monitorIconsFont
    ];
  };
}
