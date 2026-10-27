{ ... }:
{
  config.my.features.nixos.gaming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      discord
      spotify
      wowup-cf
      curseforge
      faugus-launcher
      amdtop
      vulkan-tools
    ];

    programs = {
      steam.enable = true;
      gamemode.enable = true;
    };

    networking.firewall.allowedUDPPorts = [ 5353 ];
    networking.firewall.allowedTCPPorts = [ 57621 ];
  };
}
