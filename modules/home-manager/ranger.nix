{ pkgs, ... }:
{
  programs.ranger = {
    enable = true;
    settings = {
      preview_images = false;
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
  ];
}
