{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
    discord
    spotify
    lutris
    wowup-cf
    protonup-rs
  ];

  programs = {
    steam = {
      enable = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
