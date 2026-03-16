{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontpreview
    nerd-fonts.jetbrains-mono
    nerd-fonts.terminess-ttf
    maple-mono.truetype
  ];
}
