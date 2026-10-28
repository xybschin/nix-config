{
  config,
  lib,
  pkgs,
  ...
}:
let
  qs = lib.getExe' pkgs.quickshell "qs";

  # Owned by the shared.desktop.monitors feature; null when unset.
  gamingWorkspace = config.my.monitors.gamingWorkspace;
in
{
  home.packages = with pkgs; [
    playerctl
  ];

  # Use our own themed layout instead of stylix's default waybar theme,
  # which injects per-id padding rules and 3px workspace borders that
  # override our custom styling.
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = [
      {
        position = "bottom";
        layer = "bottom";
        margin = "0";
        height = 48;
        modules-left = [
          "custom/nixos"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-right = [
          "wireplumber#source"
          "wireplumber"
          "network"
          "memory"
          "cpu"
          "clock"
          "tray"
          "custom/notification"
          "custom/monitor"
          "custom/power"
        ];
        "hyprland/workspaces" = {
          format = "{icon}";
          all-outputs = true;
          warp-on-scroll = false;
          # Base list is curated here; the gaming workspace joins from data.
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
          }
          // lib.optionalAttrs (gamingWorkspace != null) { "${toString gamingWorkspace}" = [ ]; };
          format-icons = lib.optionalAttrs (gamingWorkspace != null) {
            "${toString gamingWorkspace}" = "󰸳";
          };
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip = false;
        };
        cpu = {
          format = "CPU {usage}%";
          tooltip = false;
        };
        memory = {
          format = "MEM {}%";
        };
        network = {
          format-ethernet = "({ifname}) DOWN {bandwidthDownBits} UP {bandwidthUpBits}";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "{ifname} NO IP";
          format-disconnected = "DISCONNECTED";
          interval = 4;
        };
        wireplumber = {
          format = "SNK {volume}%";
          format-muted = "SNK 0%";
          on-click = "pwvucontrol";
          on-click-right = "audio-control";
          on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "wireplumber#source" = {
          node-type = "Audio/Source";
          format = "SRC {volume}%";
          format-muted = "SRC 0%";
          on-click = "pwvucontrol";
          on-click-right = "audio-control";
          on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        "custom/nixos" = {
          format = "";
          tooltip = false;
          on-click = "qs ipc call launcher toggle";
        };
        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "${qs} ipc call powermenu toggle";
        };
        "custom/monitor" = {
          format = "󰍺";
          tooltip = false;
          on-click = "${qs} ipc call monitormenu toggle";
        };
        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
        };
        tray = {
          icon-size = 16;
          spacing = 10;
        };
        "custom/notification" = {
          "tooltip" = true;
          "format" = "{icon}";
          "format-icons" = {
            "notification" = "󱅫";
            "none" = "󰂜";
            "dnd-notification" = "󰂠";
            "dnd-none" = "󰪓";
            "inhibited-notification" = "󰂛";
            "inhibited-none" = "󰪑";
            "dnd-inhibited-notification" = "󰂛";
            "dnd-inhibited-none" = "󰪑";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          "exec" = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          "escape" = true;
        };
      }
    ];

    style =
      let
        c = config.lib.stylix.colors;
      in
      ''
        @define-color base00      #${c.base00};
        @define-color base00Alpha alpha(#${c.base00}, 0.67);
        @define-color base01      #${c.base01};
        @define-color base03      #${c.base03};
        @define-color base04      #${c.base04};
        @define-color base05      #${c.base05};
        @define-color base05Alpha alpha(#${c.base05}, 0.07);
        @define-color base06      #${c.base06};
        @define-color base07      #${c.base07};
        @define-color base08      #${c.base08};
        @define-color base0A      #${c.base0A};
        @define-color base0D      #${c.base0D};
        @define-color base0C      #${c.base0C};
        @define-color base0E      #${c.base0E};
        @define-color base0F      #${c.base0F};

        window#waybar {
            border: 1px solid @base01;
        }

        window#waybar, tooltip {
            background: @base00Alpha;
            color: @base05;
        }

        * {
            font-family: FontAwesome, "Terminess Nerd Font Mono";
            font-size: ${toString config.stylix.fonts.sizes.desktop}pt;
        }

        button {
            border: none;
            border-radius: 0;
        }

        button:hover {
            background: inherit;
        }

        #custom-nixos {
            margin: 2px 21px;
            font-size: 42px;
            color: @base03;
        }

        #window {
            margin-left: 24px;
        }

        #bluetooth.disabled,
        #bluetooth.off {
            color: @base03;
        }

        #bluetooth.connected {
            color: @base0C;
        }

        #workspaces button,
        .modules-right > widget > *
        {
            color: @base04;
            background: @base00;
            border: 1px solid @base05Alpha;
            border-radius: 3px;
            padding: 0 10px;
            margin: 6px 2px 6px 0px;
        }

        .modules-right > widget > * {
            color: @base07;
        }

        #workspaces button.active,
        #workspaces button.active
        {
            background: @base05Alpha;
            color: @base06;
        }

        .modules-right > widget:last-child > * {
            margin-right: 4;
        }

        #custom-power,
        #custom-monitor,
        #custom-notification {
            font-size: 24px;
        }
      '';
  };

  xdg.configFile."waybar/scripts".source = config.lib.file.mkOutOfStoreSymlink ./scripts;
}
