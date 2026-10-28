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

          # Wait for the daemon to discover the mouse; the wireless dongle
          # can take a few seconds after login.
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
          exec razer-cli -d "$name" \
            --dpi ${toString mouseSettings.dpi} \
            --poll ${toString mouseSettings.pollRate} \
            --battery low ${toString mouseSettings.lowBatteryPercent} idle ${toString mouseSettings.idleSeconds} \
            --effect ${mouseSettings.effect} --color '${mouseSettings.color}' --brightness ${toString mouseSettings.brightness}
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

      systemd.user.services.razer-apply = {
        description = "Apply declarative settings to Razer devices";
        wants = [ "openrazer-daemon.service" ];
        after = [ "openrazer-daemon.service" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
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
    };
}
