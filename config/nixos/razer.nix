{ ... }:
{
  config.my.features.nixos.razer =
    { pkgs, ... }:
    let
      mouseSettings = {
        dpi = 700;
        pollRate = 1000;
        lowBatteryPercent = 10;
        idleSeconds = 600;
        effect = "static";
        color = "ffffff";
        brightness = 15;
      };

      razerApply = pkgs.writeShellApplication {
        name = "razer-apply";
        runtimeInputs = with pkgs; [
          razer-cli
          coreutils
          gnused
        ];
        text = ''
          set -euo pipefail

          name=""
          for _ in $(seq 1 45); do
            name="$(razer-cli -l 2>/dev/null | sed -n 's/^\(Razer Naga Pro.*\):$/\1/p' | head -n1)" || true
            if [ -n "$name" ]; then
              break
            fi
            sleep 2
          done

          if [ -z "$name" ]; then
            echo "razer-apply: Naga Pro not present, keeping current settings" >&2
            exit 0
          fi

          echo "razer-apply: configuring $name"
          sleep 3

          for i in $(seq 1 5); do
            if razer-cli -d "$name" \
              --dpi ${toString mouseSettings.dpi} \
              --poll ${toString mouseSettings.pollRate} \
              --battery low ${toString mouseSettings.lowBatteryPercent} idle ${toString mouseSettings.idleSeconds} \
              --effect ${mouseSettings.effect} --color '${mouseSettings.color}' --brightness ${toString mouseSettings.brightness}; then
              echo "razer-apply: successfully applied settings"
              exit 0
            fi
            echo "razer-apply: failed to apply, retrying in 3s (attempt $i/5)..." >&2
            sleep 3
          done

          echo "razer-apply: error: failed to apply settings after multiple attempts" >&2
          exit 1
        '';
      };
    in
    {
      hardware.openrazer = {
        enable = true;
        batteryNotifier = {
          enable = false;
          frequency = 600;
          percentage = 20;
        };
      };

      # Keep this out of the graphical-session transaction. It polls for up
      # to 90s when the mouse is absent, and systemd won't activate a target
      # until its wanted jobs finish — so being WantedBy
      # graphical-session.target delayed xdg-desktop-autostart (waybar,
      # hyprpaper, ...) by ~95s and left the desktop black after login.
      # The daemon is all this needs, not a compositor.
      systemd.user.services.razer-apply = {
        description = "Apply declarative settings to Razer devices";
        wants = [ "openrazer-daemon.service" ];
        after = [ "openrazer-daemon.service" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${razerApply}/bin/razer-apply";
          TimeoutStartSec = 180;
        };
      };

      environment.systemPackages = with pkgs; [
        openrazer-daemon
        razer-cli
      ];

      # OpenRazer only handles DPI/lighting; it can't rebind buttons. The
      # Naga's 12-button plate emits standard HID number-row or numpad keys
      # over the mouse's own keyboard interface depending on the underside
      # hardware switch — remap both sets of usages to F1-F12 at the udev
      # level (no daemon) so the switch position doesn't matter. Modaliases
      # are scoped to the Naga's vendor/product IDs (dongle + wired), so the
      # real keyboard's digits/numpad are untouched.
      services.udev.extraHwdb = ''
        evdev:input:b0003v1532p0090*
         KEYBOARD_KEY_7001e=f1
         KEYBOARD_KEY_7001f=f2
         KEYBOARD_KEY_70020=f3
         KEYBOARD_KEY_70021=f4
         KEYBOARD_KEY_70022=f5
         KEYBOARD_KEY_70023=f6
         KEYBOARD_KEY_70024=f7
         KEYBOARD_KEY_70025=f8
         KEYBOARD_KEY_70026=f9
         KEYBOARD_KEY_70027=f10
         KEYBOARD_KEY_7002d=f11
         KEYBOARD_KEY_7002e=f12
         KEYBOARD_KEY_70056=f11
         KEYBOARD_KEY_70057=f12
         KEYBOARD_KEY_70059=f1
         KEYBOARD_KEY_7005a=f2
         KEYBOARD_KEY_7005b=f3
         KEYBOARD_KEY_7005c=f4
         KEYBOARD_KEY_7005d=f5
         KEYBOARD_KEY_7005e=f6
         KEYBOARD_KEY_7005f=f7
         KEYBOARD_KEY_70060=f8
         KEYBOARD_KEY_70061=f9
         KEYBOARD_KEY_70062=f10

        evdev:input:b0003v1532p008f*
         KEYBOARD_KEY_7001e=f1
         KEYBOARD_KEY_7001f=f2
         KEYBOARD_KEY_70020=f3
         KEYBOARD_KEY_70021=f4
         KEYBOARD_KEY_70022=f5
         KEYBOARD_KEY_70023=f6
         KEYBOARD_KEY_70024=f7
         KEYBOARD_KEY_70025=f8
         KEYBOARD_KEY_70026=f9
         KEYBOARD_KEY_70027=f10
         KEYBOARD_KEY_7002d=f11
         KEYBOARD_KEY_7002e=f12
         KEYBOARD_KEY_70056=f11
         KEYBOARD_KEY_70057=f12
         KEYBOARD_KEY_70059=f1
         KEYBOARD_KEY_7005a=f2
         KEYBOARD_KEY_7005b=f3
         KEYBOARD_KEY_7005c=f4
         KEYBOARD_KEY_7005d=f5
         KEYBOARD_KEY_7005e=f6
         KEYBOARD_KEY_7005f=f7
         KEYBOARD_KEY_70060=f8
         KEYBOARD_KEY_70061=f9
         KEYBOARD_KEY_70062=f10
      '';
    };
}
