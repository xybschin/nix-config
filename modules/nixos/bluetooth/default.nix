{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf config.my.bluetooth.enable {
    environment.systemPackages = with pkgs; [
      bluetui
    ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          ControllerMode = "dual";
          FastConnectable = true;
          Experimental = true;
          JustWorksRepairing = "always";
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
        };
        LE = {
          MinConnectionInterval = 6;
          MaxConnectionInterval = 12;
          ConnectionLatency = 0;
          ConnectionSupervisionTimeout = 200;
        };
      };
    };

    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=0
    '';
  };
}
