{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.razer = {
    enable = lib.mkEnableOption "Razer devices (openrazer)";

    dpi = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "DPI to set on all Razer mice after openrazer-daemon starts (e.g. 1000).";
    };
  };

  config = lib.mkIf config.my.razer.enable {
    hardware.openrazer.enable = true;

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
      razer-cli
    ];

    systemd.user.services.razer-dpi = lib.mkIf (config.my.razer.dpi != null) {
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
        ${pkgs.razer-cli}/bin/razer-cli --dpi ${toString config.my.razer.dpi}
      '';
    };
  };
}
