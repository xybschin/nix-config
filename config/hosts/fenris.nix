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
          "kvm"
          "libvirtd"
          "video"
          "render"
          "lpadmin"
        ];
        shell = pkgs.zsh;
        hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
      };

      boot.extraModprobeConfig = "options hid_apple fnmode=2";

      boot.loader.timeout = 10;
      boot.loader.systemd-boot.extraEntries = {
        "bazzite.conf" = ''
          title Bazzite
          efi /EFI/fedora/grubx64.efi
          sort-key @bazzite
        '';
      };

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
      "1password"
      "coding-agents"
      "terminals"
      "mangohud"
      "waybar-audio-control"
      "rvm-webcam"
      "shared.desktop"
      "shared.desktop.wm.hyprland"
      "shared.vscode"
    ];
    home.configuration = { pkgs, ... }: {
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
              timeout = 300;
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

      home.packages =
        with pkgs;
        [
          obsidian
          python3
          nodejs
          tigervnc
          vlc
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.google-chrome
          pkgs.zathura
        ];

      services.xembed-sni-proxy.enable = true;

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
          "text/html" = "zen.desktop";
          "x-scheme-handler/http" = "zen.desktop";
          "x-scheme-handler/https" = "zen.desktop";
          "inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };

      programs.git = {
        enable = true;
        settings = {
          user.name = "xybschin";
          user.email = "hello@bjarneschindler.dev";
          extraConfig.credential.helper = "store";
          color.ui = true;
          init.defaultBranch = "main";
        };
      };

      xdg.configFile."hypr/binds.user.lua".source = ./_fenris/hyprland-user/binds.user.lua;
      xdg.configFile."hypr/rules.user.lua".source = ./_fenris/hyprland-user/rules.user.lua;
      xdg.configFile."hypr/autostart.user.lua".source = ./_fenris/hyprland-user/autostart.user.lua;
      xdg.configFile."hypr/settings.user.lua".source = ./_fenris/hyprland-user/settings.user.lua;
      xdg.configFile."hypr/scripts/rofi-monitor-menu".source = ./_fenris/scripts/rofi-monitor-menu;
      xdg.configFile."hypr/scripts/monitor-config".source = ./_fenris/scripts/monitor-config;
    };
  };
}
