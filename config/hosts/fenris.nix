{ ... }:
{
  config.my.hosts.fenris = {
    system = "x86_64-linux";
    username = "moonz";
    isWsl = false;

    nixos.features = [
      "common"
      "desktop"
      "hyprland"
      "audio"
      "bluetooth"
      "boot"
      "1password"
      "brave-browser"
      "gnome-keyring"
      "gaming"
      "razer"
      "logiops"
      "usb-auto-mount"
      "virtualisation"
      "podman"
      "printing"
      "wireguard"
      "v4l2loopback"
    ];
    nixos.extraModules = [ ./_fenris/hardware.nix ];
    nixos.configuration = { pkgs, ... }: {
      networking.hostName = "fenris";

      boot.kernelParams = [
        "amd_pstate=active"
        "pcie_aspm=off"
        "usbcore.autosuspend=-1"
        "video=DP-3:d"
      ];

      users.users.moonz = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "gamemode"
          "networkmanager"
          "openrazer"
          "video"
          "render"
          "lpadmin"
        ];
        shell = pkgs.zsh;
        hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
      };

      boot.extraModprobeConfig = "options hid_apple fnmode=2";

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      environment.systemPackages = with pkgs; [
        geary
        gnupg
        efibootmgr
      ];
    };

    home.features = [
      "global"
      "git-identity"
      "1password"
      "coding-agents"
      "devenv"
      "workmux"
      "terminals"
      "mangohud"
      "waybar-audio-control"
      "xembsni"
      "lfbw"
      "shared.desktop"
      "shared.desktop.wm.hyprland"
      "shared.desktop.monitors"
      "shared.vscode"
    ];
    home.configuration =
      { config, pkgs, ... }:
      {
        my.monitors = {
          profiles = [
            {
              glyph = config.my.monitors.glyphs.DualActive;
              outputs = [
                {
                  name = "DP-2";
                  mode = "2560x1440@120";
                  position = "0x0";
                  workspaces = [
                    1
                    3
                    5
                    7
                    9
                    10
                  ];
                }
                {
                  name = "HDMI-A-1";
                  mode = "2560x1440@120";
                  position = "2560x0";
                  workspaces = [
                    2
                    4
                    6
                    8
                  ];
                }
              ];
            }
            {
              glyph = config.my.monitors.glyphs.DualLeftActive;
              outputs = [
                {
                  name = "DP-2";
                  mode = "2560x1440@120";
                  position = "0x0";
                  workspaces = [
                    1
                    2
                    3
                    4
                    5
                    6
                    7
                    8
                    9
                    10
                  ];
                }
                {
                  name = "HDMI-A-1";
                  enabled = false;
                }
              ];
            }
            {
              glyph = config.my.monitors.glyphs.DualRightActive;
              outputs = [
                {
                  name = "HDMI-A-1";
                  mode = "2560x1440@120";
                  position = "0x0";
                  workspaces = [
                    1
                    2
                    3
                    4
                    5
                    6
                    7
                    8
                    9
                    10
                  ];
                }
                {
                  name = "DP-2";
                  enabled = false;
                }
              ];
            }
            {
              glyph = config.my.monitors.glyphs.Ultrawide;
              outputs = [
                {
                  name = "DP-2";
                  mode = "5120x1440@144";
                  position = "0x0";
                  workspaces = [
                    1
                    2
                    3
                    4
                    5
                    6
                    7
                    8
                    9
                    10
                  ];
                }
                {
                  name = "HDMI-A-1";
                  enabled = false;
                }
              ];
            }
          ];
          alwaysDisabled = [ "DP-3" ];
          gamingWorkspace = 10;
        };

        my.coding-agents.agents = [ "opencode" ];

        services.lfbw = {
          enable = true;
          settings.background = "file=${./_fenris/webcam-backgrounds/pub.png}";
        };

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              after_sleep_cmd = "hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
            };

            listener = [
              {
                timeout = 300;
                on-timeout = "hyprlock";
              }
              {
                timeout = 360;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
              {
                timeout = 1800;
                on-timeout = "systemctl hibernate";
              }
            ];
          };
        };

        home.packages = with pkgs; [
          obsidian
          signal-desktop
          python3
          nodejs
          tigervnc
          vlc
        ];

        xdg.mime.enable = true;
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = "org.pwmt.zathura.desktop";
            "image/png" = "feh.desktop";
            "image/jpeg" = "feh.desktop";
            "image/gif" = "feh.desktop";
            "video/mp4" = "vlc.desktop";
            "video/webm" = "vlc.desktop";
            "video/x-matroska" = "vlc.desktop";
            "audio/mpeg" = "vlc.desktop";
            "audio/ogg" = "vlc.desktop";
            "audio/flac" = "vlc.desktop";
            "text/html" = "brave-browser.desktop";
            "application/xhtml+xml" = "brave-browser.desktop";
            "x-scheme-handler/http" = "brave-browser.desktop";
            "x-scheme-handler/https" = "brave-browser.desktop";
            "inode/directory" = "org.gnome.Nautilus.desktop";
          };
        };

        xdg.configFile."hypr/binds.user.lua".source = ./_fenris/hyprland-user/binds.user.lua;
        xdg.configFile."hypr/rules.user.lua".source = ./_fenris/hyprland-user/rules.user.lua;
      };
  };
}
