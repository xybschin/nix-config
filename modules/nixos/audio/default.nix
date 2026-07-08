{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.audio.enable = lib.mkEnableOption "Audio (PipeWire)";

  config = lib.mkIf config.my.audio.enable {
    environment.systemPackages = with pkgs; [
      pavucontrol
      easyeffects
      pulseaudio
    ];

    security.rtkit.enable = true;

    services = {
      pulseaudio = {
        enable = false;
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };
}
