{ ... }:
{
  # Monitor profiles: switchable layouts for Hyprland, declared as data.
  # One definition generates the Hyprland Lua (~/.config/hypr/monitors.lua),
  # the `monitor-config` state script and the data for the quickshell
  # monitor menu (~/.config/koda/monitor-menu.json).
  #
  # The active profile is the name stored in a state file; the first profile
  # is the default. Names are positional (profile1, profile2, …) and
  # persisted per machine, so reordering profiles changes what a saved state
  # selects. Needs the Hyprland feature (which loads the Lua and runs the
  # quickshell MonitorMenu).
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

      # Codepoints the bundled MonitorIcons font provides (fc-query: f5000-f5003).
      availableGlyphs = [
        "F5000"
        "F5001"
        "F5002"
        "F5003"
        "F5004"
      ];

      # Names and icon escapes are derived, not declared: profile1, profile2, …
      # and $'…' escapes the shell menu needs. The state file persists names,
      # so reordering profiles changes what a saved state selects.
      profiles = lib.imap0 (
        i: p:
        p
        // {
          name = "profile${toString (i + 1)}";
          glyph = "\\U000${p.glyph}";
        }
      ) cfg.profiles;

      # Shared by the script (writes it) and the Lua (reads it).
      stateFileName = "hyprland-monitor-profile";

      default = (lib.head profiles).name;

      monitorConfig = pkgs.writeShellScript "monitor-config" ''
        set -euo pipefail
        readonly STATE_DIR="''${XDG_STATE_HOME:-"$HOME/.local/state"}"
        readonly STATE_FILE="$STATE_DIR/${stateFileName}"
        mkdir -p "$STATE_DIR"

        validate_profile() {
            case "$1" in
        ${lib.concatMapStrings (p: "        ${p.name}) ;;\n") profiles}        *)
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

      monitorIconsFont = pkgs.runCommand "monitor-icons-font" { } ''
        install -Dm644 ${./_desktop/monitors/MonitorIcons.ttf} \
          $out/share/fonts/truetype/MonitorIcons.ttf
      '';

      glyphs = map (p: p.glyph) profiles;
      unique = l: lib.length l == lib.length (lib.unique l);
    in
    {
      options.my.monitors = {
        glyphs = lib.mkOption {
          type = lib.types.attrsOf (lib.types.enum availableGlyphs);
          default = {
            DualActive = "F5000";
            DualLeftActive = "F5001";
            DualRightActive = "F5002";
            Ultrawide = "F5003";
            Single = "F5004";
          };
          readOnly = true;
          description = "Named icons of the bundled MonitorIcons font, keyed by what they depict; reference as `config.my.monitors.glyphs.<Name>`.";
        };
        profiles = lib.mkOption {
          default = [ ];
          description = "Layout profiles, in menu order; the first is the default.";
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                glyph = lib.mkOption {
                  type = lib.types.enum availableGlyphs;
                  description = "Icon that depicts this layout; take one from `my.monitors.glyphs`.";
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
            assertion = unique glyphs;
            message = "monitors: profile glyphs must be unique.";
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
        ]) profiles;

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
          ) profiles;
          applyScript = toString monitorConfig;
        };

        # The quickshell MonitorMenu reads this: one tile per profile.
        xdg.configFile."koda/monitor-menu.json".text = builtins.toJSON (
          lib.zipListsWith (p: raw: {
            codepoint = raw.glyph;
            command = "${monitorConfig} ${p.name}";
          }) profiles cfg.profiles
        );

        home.packages = [ monitorIconsFont ];
      };
    };
}
