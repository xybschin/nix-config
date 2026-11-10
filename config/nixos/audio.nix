{ ... }:
{
  config.my.features.nixos.audio = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pwvucontrol
      easyeffects
      pulseaudio
      # JACK clients go through `pw-jack` instead of a global LD_LIBRARY_PATH.
      pipewire.jack
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
      };
    };
  };
}
