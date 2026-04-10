{ ... }:
{
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
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
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
          format = "{icon}";
          format-icons = {
            "6" = "G";
          };
        };
        clock = {
          format = "{:%Y-%d-%m %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "({ifname}) {ipaddr}/{cidr} DOWN {bandwidthDownBits} UP {bandwidthUpBits}";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          interval = 4;
        };
        pulseaudio = {
          format = "VOL {volume}%";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
        "custom/media" = {
          format = "NOW PLAYING: {}";
          exec = "playerctl metadata --format '{{title}} - {{artist}}'";
          interval = 5;
          max-length = 80;
          escape = true;
          tooltip = true;
          tooltip-format = "{}";
        };
        tray = {
          icon-size = 21;
          spacing = 10;
          icons = {
            blueman = "bluetooth";
            TelegramDesktop = "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png";
          };
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
}
