{ ... }:
{
  config.my.features.nixos.razer = { pkgs, ... }: {
    hardware.openrazer.enable = true;

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
      razer-cli
    ];
  };
}
