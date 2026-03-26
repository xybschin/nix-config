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
        # Allow BT classic + LE dual mode
        ControllerMode = "dual";
        # Faster reconnection for paired devices (uses more power)
        FastConnectable = true;
        # Enable battery reporting and experimental codec support
        Experimental = true;
      };
      LE = {
        # Tighter connection interval for lower HID latency (in ms)
        MinConnectionInterval = 7;
        MaxConnectionInterval = 9;
        ConnectionLatency = 0;
      };
    };
  };

  # Prevent the BT USB adapter from being autosuspended,
  # which can cause brief disconnects and key repeat stuttering
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';
}
