{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    playerctl
    # 1Password CLI is used by waybar's openrouter-credits script to fetch
    # the OpenRouter API key from the user's vault.
    _1password-cli
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
          "custom/openrouter"
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
        "custom/openrouter" = {
          format = "{}";
          exec = "${config.xdg.configHome}/waybar/scripts/openrouter-credits";
          return-type = "json";
          interval = 3600;
          # exec-on-event defaults to true, so any click re-runs the script
          # for an immediate refresh.
          on-click = "${config.xdg.configHome}/waybar/scripts/openrouter-credits";
          tooltip = true;
        };
        tray = {
          icon-size = 16;
          spacing = 10;
        };
      }
    ];

    style = let c = config.lib.stylix.colors; in ''
      @define-color base00 #${c.base00};
      @define-color base01 #${c.base01};
      @define-color base03 #${c.base03};
      @define-color base05 #${c.base05};
      @define-color base08 #${c.base08};
      @define-color base0D #${c.base0D};

      window#waybar, tooltip {
          background: @base00;
          color: @base05;
      }

      * {
          font-family: FontAwesome, "Terminess Nerd Font";
          font-size: ${toString config.stylix.fonts.sizes.desktop}pt;
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

      #custom-openrouter.warning {
          color: @base08;
      }

      #custom-openrouter.error {
          color: @base08;
      }

      #workspaces button {
          background-color: @base01;
          color: @base05;
          border-bottom: 1px solid @base03;
      }

      #workspaces button.active {
          background-color: @base0D;
          color: @base01;
      }

      .modules-right > widget > * {
          margin: 8px 0;
          padding: 0 1rem;
          border-right: 1px solid @base03;
      }

      .modules-right > widget:last-child > * {
          margin-right: 0;
          border: 0;
      }
    '';
  };

  xdg.configFile."waybar/scripts".source = config.lib.file.mkOutOfStoreSymlink ./scripts;
}
