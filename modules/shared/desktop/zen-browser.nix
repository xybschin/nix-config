{
  lib,
  pkgs,
  inputs,
  config,
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

        # Match stylix's firefox target: 4/3 pt→px conversion with 0.5 rounding.
        # stylix's zen-browser module only sets font names, not sizes.
        "font.size.monospace.x-western" = builtins.floor (
          (config.stylix.fonts.sizes.terminal * 4.0 / 3.0) + 0.5
        );
        "font.size.variable.x-western" = builtins.floor (
          (config.stylix.fonts.sizes.applications * 4.0 / 3.0) + 0.5
        );
      };
    };
  };
}
