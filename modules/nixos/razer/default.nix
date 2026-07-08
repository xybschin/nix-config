{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.razer.enable = lib.mkEnableOption "Razer devices (openrazer)";

  config = lib.mkIf config.my.razer.enable {
    hardware.openrazer.enable = true;
    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];
  };
}
