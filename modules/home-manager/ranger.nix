{ pkgs, ... }:
{
  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
    };
  };

  home.packages = with pkgs; [
    file
    imagemagick
    ffmpeg
    unzip
    mediainfo
    jq
    librsvg
    lynx
    w3m
  ];
}
