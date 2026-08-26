{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  pkgsUnfree = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    overlays = [ inputs.firefox-addons.overlays.default ];
  };

  addons = pkgsUnfree.firefox-addons;
in
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
      extensions.packages = with addons; [
        ublock-origin
        purpleadblock
        dearrow
        vimium
        privacy-badger
        onepassword-password-manager
        untrap-for-youtube
      ];

      settings = {
        "media.ffmpeg.vaapi.enabled" = lib.mkForce true;
        "media.hardware-video-decoding.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "media.rdd-vpx.enabled" = true;
        "media.ffmpeg.vaapi-drm-display.enabled" = true;
        "general.autoScroll" = true;
        "browser.aboutConfig.showWarning" = false;
        "zen.glance.enabled" = false;
        "browser.translations.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
      };

      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "c";
          modifiers = {
            alt = true;
          };
        }
        {
          id = "zen-toggle-sidebar";
          key = "s";
          modifiers = {
            alt = true;
          };
        }
      ];
    };
  };
}
