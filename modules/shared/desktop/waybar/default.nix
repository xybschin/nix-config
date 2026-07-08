{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ playerctl ];

  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = [
      {
        position = "bottom";
        layer = "bottom";
        modules-left = [
          "hyprland/workspaces"
          "custom/media"
        ];
        modules-right = [
          "pulseaudio#source"
          "pulseaudio"
          "network"
          "memory"
          "cpu"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          all-outputs = true;
          warp-on-scroll = false;
        };
        clock = {
          format = "{:%Y-%d-%m %H:%M}";
          format-alt = "{:%Y-%m-%d}";
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
        pulseaudio = {
          format = "SNK {volume}%";
          format-muted = "SNK 0%";
          on-click = "pavucontrol --tab 3";
          on-click-right = "audio-control";
          on-click-middle = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        "pulseaudio#source" = {
          format = "{format_source}";
          format-source = "SRC {volume}%";
          format-source-muted = "SRC 0%";
          on-click = "pavucontrol --tab 4";
          on-click-right = "audio-control";
          on-click-middle = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
          on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
        };
        "custom/media" = {
          format = "NOW PLAYING: {}";
          exec = "${config.xdg.configHome}/waybar/scripts/scrolling-playerctl";
          tooltip = true;
          tooltip-format = "{}";
          on-click = "playerctl play-pause";
        };
        tray = {
          icon-size = 16;
          spacing = 10;
        };
      }
    ];

    style = ''
      * {
          font-family: FontAwesome, "Terminess Nerd Font";
      }

      button {
          border: none;
          border-radius: 0;
      }

      button:hover {
          background: inherit;
      }

      #custom-arch {
          min-width: 52px;
      }

      #custom-media {
          margin-left: 24px;
      }

      .modules-right > widget > * {
          margin: 8px 0;
          padding: 0px 2rem;
          border-right: 1px solid @base03;
      }

      .modules-right > widget:last-child > * {
          margin-right: 0;
          border: 0px;
      }
    '';
  };

  xdg.configFile."waybar/scripts".source = config.lib.file.mkOutOfStoreSymlink ./scripts;
}
