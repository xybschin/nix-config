{ config, pkgs, ... }:
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
        @define-color base08      #${c.base08};
        @define-color base0A      #${c.base0A};
        @define-color base0D      #${c.base0D};
        @define-color base0C      #${c.base0C};
        @define-color base0E      #${c.base0E};
        @define-color base0F      #${c.base0F};

        window#waybar {
            border-top: 1px solid @base01;
        }

        window#waybar, tooltip {
            background: @base00Alpha;
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
            color: @base0A;
        }

        #custom-openrouter.error {
            color: @base0F;
        }

        #bluetooth.disabled,
        #bluetooth.off {
            color: @base03;
        }

        #bluetooth.connected {
            color: @base0C;
        }

        #workspaces button {
            border-top: 1px solid @base01;
            background-color: @base01;
            color: @base04;
        }

        #workspaces button.active {
            background-color: @base0C;
            color: @base07;
        }

        .modules-right > widget > * {
            margin: 8px 0;
            padding: 0 1rem;
            border-right: 1px solid @base01;
        }

        .modules-right > widget:last-child > * {
            margin-right: 0;
            border: 0;
        }
      '';
  };

  xdg.configFile."waybar/scripts".source = config.lib.file.mkOutOfStoreSymlink ./scripts;

  # OpenRouter API key for the openrouter-credits widget. Encrypted via sops
  # and decrypted at activation by the sops-nix user service. waybar must
  # order after sops-nix and read the key via EnvironmentFile (not
  # environment.d, which races with sops-nix decryption).
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";
  sops.secrets.openrouter = {
    sopsFile = ../../../../secrets/openrouter.env;
    format = "dotenv";
  };

  systemd.user.services.waybar = {
    Service.EnvironmentFile = [ config.sops.secrets.openrouter.path ];
    Unit.After = [ "sops-nix.service" ];
    Unit.Wants = [ "sops-nix.service" ];
  };
}
