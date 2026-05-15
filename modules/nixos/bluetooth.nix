{ pkgs, ... }:

{
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
        # Re-pair silently without prompting the user
        JustWorksRepairing = "always";
      };
      Policy = {
        # Retry reconnection up to 7 times with exponential backoff (seconds)
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
      LE = {
        MinConnectionInterval = 6;
        MaxConnectionInterval = 12;
        ConnectionLatency = 0;
        # Detect dropped connections in ~2s instead of the default 32s
        ConnectionSupervisionTimeout = 200;
      };
    };
  };

  # Prevent the BT USB adapter from being autosuspended,
  # which can cause brief disconnects and key repeat stuttering
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';
}
