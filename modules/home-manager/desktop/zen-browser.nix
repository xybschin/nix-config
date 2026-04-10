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

  programs.zen-browser = {
    enable = true;

    profiles."*" = {
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
        "media.rdd-vpx.enabled" = true;
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi-drm-display.enabled" = true;
      };
    };
  };
}
