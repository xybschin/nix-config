{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (config.lib.stylix.colors) base00-hex base01-hex base02-hex base03-hex base05-hex base0B-hex base0C-hex base0D-hex base0E-hex base0F-hex;
  inherit (config.stylix.targets.zen-browser) opacityHex;
in
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

      # Disable stylix's userContent to avoid merge conflict; we provide our own
      # below with the same theme + a visible ::selection fix.
      userContent = lib.mkForce ''
        /* Common variables affecting all pages */
        @-moz-document url-prefix("about:") {
          :root {
            --in-content-page-color: #${base05-hex} !important;
            --color-accent-primary: #${base0D-hex} !important;
            --color-accent-primary-hover: #${base0D-hex} !important;
            --color-accent-primary-active: #${base0D-hex} !important;
            background-color: #${base00-hex}${opacityHex} !important;
            --in-content-page-background: #${base00-hex}${opacityHex} !important;
            --background-color-canvas: #${base00-hex}${opacityHex} !important;
          }

          input {
            background-color: #${base02-hex}${opacityHex} !important;
          }
        }

        /* Variables and styles specific to about:newtab and about:home */
        @-moz-document url("about:newtab"), url("about:home") {

          :root {
            --newtab-background-color: #${base00-hex}${opacityHex} !important;
            --newtab-background-color-secondary: #${base02-hex}${opacityHex} !important;
            --newtab-element-hover-color: #${base02-hex} !important;
            --newtab-text-primary-color: #${base05-hex} !important;
            --newtab-wordmark-color: #${base05-hex} !important;
            --newtab-primary-action-background: #${base0D-hex}${opacityHex} !important;
          }

          .icon {
            color: #${base0D-hex} !important;
          }

          .search-wrapper .logo-and-wordmark .logo {
            display: inline-block !important;
            height: 82px !important;
            width: 82px !important;
            background-size: 82px !important;
          }

          @media (max-width: 609px) {
            .search-wrapper .logo-and-wordmark .logo {
              background-size: 64px !important;
              height: 64px !important;
              width: 64px !important;
            }
          }

          .card-outer:is(:hover, :focus, .active):not(.placeholder) .card-title {
            color: #${base0D-hex} !important;
          }

          .top-site-outer .search-topsite {
            background-color: #${base0D-hex}${opacityHex} !important;
          }

          .compact-cards .card-outer .card-context .card-context-icon.icon-download {
            fill: #${base0B-hex} !important;
          }
        }

        /* Variables and styles specific to about:preferences */
        @-moz-document url-prefix("about:preferences") {
          :root {
            --zen-colors-tertiary: #${base01-hex}${opacityHex} !important;
            --in-content-text-color: #${base05-hex} !important;
            --link-color: #${base0D-hex} !important;
            --link-color-hover: #${base0D-hex} !important;
            --zen-colors-primary: #${base02-hex}${opacityHex} !important;
            --in-content-box-background: #${base02-hex}${opacityHex} !important;
            --zen-primary-color: #${base0D-hex}${opacityHex} !important;
          }

          groupbox , moz-card{
            background: #${base00-hex}${opacityHex} !important;
          }

          button,
          groupbox menulist {
            background: #${base02-hex} !important;
            color: #${base05-hex} !important;
          }

          .main-content {
            background-color: #${base00-hex}${opacityHex} !important;
          }

          .identity-color-blue {
            --identity-tab-color: #${base0D-hex} !important;
            --identity-icon-color: #${base0D-hex} !important;
          }

          .identity-color-turquoise {
            --identity-tab-color: #${base0C-hex} !important;
            --identity-icon-color: #${base0C-hex} !important;
          }

          .identity-color-green {
            --identity-tab-color: #${base0B-hex} !important;
            --identity-icon-color: #${base0B-hex} !important;
          }

          .identity-color-yellow {
            --identity-tab-color: #${config.lib.stylix.colors."base0A-hex"} !important;
            --identity-icon-color: #${config.lib.stylix.colors."base0A-hex"} !important;
          }

          .identity-color-orange {
            --identity-tab-color: #${config.lib.stylix.colors."base09-hex"} !important;
            --identity-icon-color: #${config.lib.stylix.colors."base09-hex"} !important;
          }

          .identity-color-red {
            --identity-tab-color: #${config.lib.stylix.colors."base08-hex"} !important;
            --identity-icon-color: #${config.lib.stylix.colors."base08-hex"} !important;
          }

          .identity-color-pink {
            --identity-tab-color: #${base0E-hex} !important;
            --identity-icon-color: #${base0E-hex} !important;
          }

          .identity-color-purple {
            --identity-tab-color: #${base0F-hex} !important;
            --identity-icon-color: #${base0F-hex} !important;
          }
        }

        /* Variables and styles specific to about:addons */
        @-moz-document url-prefix("about:addons") {
          :root {
            --zen-dark-color-mix-base: #${base01-hex}${opacityHex} !important;
            --background-color-box: #${base00-hex}${opacityHex} !important;
          }
        }

        /* Variables and styles specific to about:protections */
        @-moz-document url-prefix("about:protections") {
          :root {
            --zen-primary-color: #${base00-hex}${opacityHex} !important;
            --social-color: #${base0E-hex} !important;
            --coockie-color: #${base0D-hex} !important;
            --fingerprinter-color: #${config.lib.stylix.colors."base0A-hex"} !important;
            --cryptominer-color: #${base0F-hex} !important;
            --tracker-color: #${base0B-hex} !important;
            --in-content-primary-button-background-hover: #${base03-hex}${opacityHex} !important;
            --in-content-primary-button-text-color-hover: #${base05-hex} !important;
            --in-content-primary-button-background: #${base03-hex}${opacityHex} !important;
            --in-content-primary-button-text-color: #${base05-hex} !important;
          }

          .card {
            background-color: #${base02-hex}${opacityHex} !important;
          }
        }

        ::selection {
          background-color: color-mix(in srgb, #${base0D-hex} 40%, transparent) !important;
          color: #${base05-hex} !important;
        }
      '';
    };
  };
}
