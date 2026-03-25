{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
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
