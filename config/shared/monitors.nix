{ ... }:
{
  # Monitor profiles: switchable layouts for Hyprland, declared as data.
  # One definition generates the Hyprland Lua (~/.config/hypr/monitors.lua),
  # the `monitor-config` state script and the rofi menu (`rofi-monitor-menu`).
  #
  # The active profile is the name stored in a state file; the first profile
  # is the default. Names are persisted per machine, so renaming one resets
  # that machine to the default. Needs rofi with the `koda-tiles` theme (the
  # `shared.desktop` feature) and the Hyprland feature (which loads the Lua).
  config.my.features.home."shared.desktop.monitors" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.monitors;
      gen = import ../_lib/monitors.nix { inherit lib; };

      # Shared by the script (writes it) and the Lua (reads it).
      stateFileName = "hyprland-monitor-profile";

      default = (lib.head cfg.profiles).name;

      monitorConfig = pkgs.writeShellScript "monitor-config" ''
        set -euo pipefail
        readonly STATE_DIR="''${XDG_STATE_HOME:-"$HOME/.local/state"}"
        readonly STATE_FILE="$STATE_DIR/${stateFileName}"
        mkdir -p "$STATE_DIR"

        validate_profile() {
            case "$1" in
        ${lib.concatMapStrings (p: "        ${p.name}) ;;\n") cfg.profiles}        *)
                    printf 'Unknown profile: %s\n' "$1" >&2
                    exit 1
                    ;;
            esac
        }

        apply_profile() {
            validate_profile "$1"
            printf '%s\n' "$1" > "$STATE_FILE"
        }

        main() {
            if [[ $# -eq 0 ]]; then
                if [[ -f "$STATE_FILE" ]]; then
                    apply_profile "$(cat "$STATE_FILE")"
                else
                    apply_profile "${default}"
                fi
            else
                apply_profile "$1"
            fi

            hyprctl reload
            ${lib.optionalString (
              cfg.restartUnits != [ ]
            ) "systemctl --user restart ${lib.concatStringsSep " " cfg.restartUnits}"}
        }

        main "$@"
      '';

      # Emits one $'…' escaped glyph per profile (rendered by MonitorIcons.ttf).
      glyphArgs = lib.concatMapStringsSep " " (p: "$'${p.glyph}'") cfg.profiles;

      # One `case` arm per profile, matching the selected glyph to its profile.
      caseArms = lib.concatMapStrings (
        p: "        $'${p.glyph}') run \"${monitorConfig} ${p.name}\" ;;\n"
      ) cfg.profiles;

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

      monitorIconsFont = pkgs.runCommand "monitor-icons-font" { } ''
        install -Dm644 ${./_desktop/monitors/MonitorIcons.ttf} \
          $out/share/fonts/truetype/MonitorIcons.ttf
      '';

      names = map (p: p.name) cfg.profiles;
      glyphs = map (p: p.glyph) cfg.profiles;
      unique = l: lib.length l == lib.length (lib.unique l);
    in
    {
      options.my.monitors = {
        profiles = lib.mkOption {
          default = [ ];
          description = "Layout profiles, in menu order; the first is the default.";
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "Profile name; also persisted in the state file.";
                };
                glyph = lib.mkOption {
                  type = lib.types.str;
                  description = "bash $'…' escaped glyph rendered by the MonitorIcons font.";
                };
                outputs = lib.mkOption {
                  description = "Every output this profile configures.";
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        name = lib.mkOption {
                          type = lib.types.str;
                          description = "Connector name, e.g. DP-2.";
                        };
                        enabled = lib.mkOption {
                          type = lib.types.bool;
                          default = true;
                        };
                        mode = lib.mkOption {
                          type = lib.types.nullOr lib.types.str;
                          default = null;
                          description = "e.g. 2560x1440@120; required when enabled.";
                        };
                        position = lib.mkOption {
                          type = lib.types.nullOr lib.types.str;
                          default = null;
                          description = "e.g. 2560x0; required when enabled.";
                        };
                        scale = lib.mkOption {
                          type = lib.types.number;
                          default = 1;
                        };
                        workspaces = lib.mkOption {
                          type = lib.types.listOf lib.types.int;
                          default = [ ];
                          description = "Workspaces pinned to this output.";
                        };
                      };
                    }
                  );
                };
              };
            }
          );
        };
        alwaysDisabled = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Outputs disabled in every profile.";
        };
        gamingWorkspace = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Workspace that gets no gaps, wherever a profile pins it.";
        };
        restartUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "hyprpaper.service"
            "waybar.service"
          ];
          description = "User units restarted after a layout change.";
        };
      };

      config = {
        assertions = [
          {
            assertion = cfg.profiles != [ ];
            message = "monitors: declare at least one profile.";
          }
          {
            assertion = unique names && unique glyphs;
            message = "monitors: profile names and glyphs must each be unique.";
          }
          {
            assertion = config.programs.rofi.enable;
            message = "monitors: the rofi menu needs rofi (the `shared.desktop` feature).";
          }
          {
            assertion =
              cfg.gamingWorkspace == null
              || lib.all (
                p: lib.any (o: o.enabled && lib.elem cfg.gamingWorkspace o.workspaces) p.outputs
              ) cfg.profiles;
            message = "monitors: the gaming workspace must be pinned on an enabled output in every profile.";
          }
        ]
        ++ lib.concatMap (p: [
          {
            assertion = lib.all (o: !o.enabled || (o.mode != null && o.position != null)) p.outputs;
            message = "monitors: every enabled output of profile `${p.name}` needs a mode and a position.";
          }
          {
            assertion =
              let
                ws = lib.concatMap (o: o.workspaces) (lib.filter (o: o.enabled) p.outputs);
              in
              unique ws && lib.all (o: o.enabled || o.workspaces == [ ]) p.outputs;
            message = "monitors: profile `${p.name}` pins a workspace twice or to a disabled output.";
          }
        ]) cfg.profiles;

        xdg.configFile."hypr/monitors.lua".text = gen.renderLua {
          inherit (cfg) alwaysDisabled gamingWorkspace;
          inherit stateFileName;
          profiles = map (
            p:
            p
            // {
              outputs = map (
                o:
                o
                // {
                  mode = toString o.mode;
                  position = toString o.position;
                }
              ) p.outputs;
            }
          ) cfg.profiles;
          applyScript = toString monitorConfig;
        };

        home.packages = [
          monitorMenu
          monitorIconsFont
        ];
      };
    };
}
