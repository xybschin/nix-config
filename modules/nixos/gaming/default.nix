{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
    lutris
    wowup-cf
  ];

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
  };
}
