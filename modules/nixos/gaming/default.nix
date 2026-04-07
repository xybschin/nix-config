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
}
