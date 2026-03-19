{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ranger
    file
    imagemagick
    ffmpeg
    unzip
    mediainfo
    jq
    librsvg
    lynx
  ];
}
