{ ... }:
{
  config.my.features.nixos.razer = { pkgs, ... }: {
    hardware.openrazer.enable = true;

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
      razer-cli
    ];

    systemd.user.services.razer-dpi = {
      description = "Set Razer mouse DPI";
      after = [ "openrazer-daemon.service" ];
      wants = [ "openrazer-daemon.service" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      script = ''
        ${pkgs.razer-cli}/bin/razer-cli --dpi 400
      '';
    };
  };
}
