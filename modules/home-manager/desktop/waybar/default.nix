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
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        "pulseaudio#source" = {
          format = "{format_source}";
          format-source = "SRC {volume}%";
          format-source-muted = "SRC 0%";
          on-click = "pavucontrol --tab 4";
          on-click-right = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
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
      @define-color background                #101010;
      @define-color selection-background      #272727;
      @define-color foreground                #ffffff;
      @define-color selection-foreground      #b0b0b0;
      @define-color divider                   #878787;
      @define-color highlight                 #d9ba73;

      * {
          font-family: FontAwesome, "Terminess Nerd Font";
          font-size: 16px;
          font-weight: 700;
      }

      window#waybar {
          background-color: alpha(@background, 0.85);
          color: @foreground;
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
          background-color: @selection-background;
          color: @arch-brand;
      }

      #custom-media {
          margin-left: 24px;
      }

      #workspaces button {
          background-color: @selection-background;
          color: @selection-foreground;
      }

      #workspaces button.active {
          background-color: @highlight;
          color: @selection-background;
      }

      .modules-right > widget > * {
          margin: 8px 0;
          padding: 0px 1rem;
          border-right: 1px solid @divider;
      }

      .modules-right > widget:last-child > * {
          margin-right: 0;
          border: 0px;
      }
    '';
  };

  xdg.configFile."waybar/scripts".source = config.lib.file.mkOutOfStoreSymlink ./scripts;
}
