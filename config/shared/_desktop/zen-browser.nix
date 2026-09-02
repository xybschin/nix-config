{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;

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
    colors.override = {
      base02-hex = c.base01;
    };
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

      userChrome = lib.mkAfter ''
        #urlbar[zen-floating-urlbar="true"] {
          background: ${c.base00} !important;
        }

        #urlbar[zen-floating-urlbar="true"] .urlbar-background {
          background: ${c.base00} !important;
        }

        .urlbarView-row {
          &[selected] {
            --zen-selected-bg: ${c.base01} !important; 
            --zen-selected-color: ${c.base05};
            background-color: ${c.base01} !important;
          }
        }

        .tab-background {
          &:is([selected], [multiselected]) {
            background-color: ${c.base01} !important;
            outline-color: var(--tab-selected-outline-color);
            box-shadow: var(--tab-box-shadow-selected);
          }
        }
      '';
    };
  };
}
