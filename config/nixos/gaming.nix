{ ... }:
{
  config.my.features.nixos.gaming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      discord
      spotify
      wowup-cf
      faugus-launcher
    ];

    programs = {
      steam.enable = true;
      gamemode.enable = true; # faugus can use it
    };

    networking.firewall.allowedUDPPorts = [ 5353 ];
    networking.firewall.allowedTCPPorts = [ 57621 ];
  };
}
