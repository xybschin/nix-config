{ ... }:
{
  config.my.hosts.fenris = {
    system = "x86_64-linux";
    username = "moonz";
    isWsl = false;

    nixos.features = [
      "common"
      "common-desktop"
      "desktop"
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
      "printing"
      "wireguard"
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
        gnupg
        efibootmgr
      ];
    };

    home.features = [
      "global"
      "git-identity"
      "1password"
      "coding-agents"
      "workmux"
      "terminals"
      "mangohud"
      "waybar-audio-control"
      "rvm-webcam"
      "xembsni"
      "shared.desktop"
      "shared.desktop.wm.hyprland"
      "shared.vscode"
    ];
    home.configuration =
      { pkgs, lib, ... }:
      let
        monitorProfiles = [
          { name = "profile1"; glyph = "\\U000F5000"; }
          { name = "profile2"; glyph = "\\U000F5001"; }
          { name = "profile3"; glyph = "\\U000F5002"; }
          { name = "profile4"; glyph = "\\U000F5003"; }
        ];

        monitorConfig = pkgs.writeShellScript "monitor-config" ''
          set -euo pipefail
          readonly STATE_DIR="''${XDG_STATE_HOME:-"$HOME/.local/state"}"
          readonly STATE_FILE="$STATE_DIR/hyprland-monitor-profile"
          mkdir -p "$STATE_DIR"

          validate_profile() {
              case "$1" in
          ${lib.concatMapStrings (p: "        ${p.name}) ;;\n") monitorProfiles}        *)
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
                      apply_profile "${(builtins.head monitorProfiles).name}"
                  fi
              else
                  apply_profile "$1"
              fi

              hyprctl reload
              systemctl --user restart hyprpaper.service waybar.service
          }

          main "$@"
        '';
      in
      {
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
      xdg.configFile."hypr/autostart.user.lua".source = ./_fenris/hyprland-user/autostart.user.lua;
      xdg.configFile."hypr/settings.user.lua".source = ./_fenris/hyprland-user/settings.user.lua;
      my.rofi.monitorProfiles = monitorProfiles;

      xdg.configFile."hypr/scripts/monitor-config".source = monitorConfig;
    };
  };
}
