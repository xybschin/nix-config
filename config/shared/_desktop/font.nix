{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    segoe-ui
    fontpreview
    nerd-fonts.terminess-ttf
    maple-mono.truetype
    corefonts
    vista-fonts
    noto-fonts
  ];
}
