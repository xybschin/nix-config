{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "Default" ];
  };

  programs.zen-browser = {
    enable = true;

    profiles."Default" = {
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        purpleadblock
        dearrow
        onepassword-password-manager
        vimium
        improved-tube
        privacy-badger
        untrap-for-youtube
      ];
      settings = {
        "media.ffmpeg.vaapi.enabled" = lib.mkForce true;
        "media.hardware-video-decoding.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "media.rdd-vpx.enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor" = true;
        "layers.acceleration.force-enabled" = true;
        "media.ffmpeg.vaapi-drm-display.enabled" = true;
        "gfx.blacklist.dmabuf" = 0;
        "media.rdd-ffmpeg.enabled" = true;
        "general.autoScroll" = true;
      };
    };
  };
}
