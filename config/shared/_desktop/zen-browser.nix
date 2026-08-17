{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # firefox-addons (NUR) marks some addons as unfree and imports its own nixpkgs
  # with a bare config, so that flake refuses to evaluate them. Vendor those here
  # with the same output layout home-manager's firefox module expects
  # ($out/share/mozilla/extensions/{GUID}/<addonId>.xpi).
  mkAddon =
    {
      name,
      version,
      addonId,
      url,
      sha256,
    }:
    pkgs.stdenv.mkDerivation {
      inherit name version addonId;
      src = pkgs.fetchurl { inherit url sha256; };
      passthru.addonId = addonId;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -m644 "$src" "$dst/${addonId}.xpi"
      '';
    };

  onepassword = mkAddon {
    name = "onepassword-password-manager-8.12.30.21";
    version = "8.12.30.21";
    addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4925154/1password_x_password_manager-8.12.30.21.xpi";
    sha256 = "eced23e1346211b19ea8f884246b5e740519226b152fca7648bf8b5502bd7e9d";
  };

  improvedTube = mkAddon {
    name = "improved-tube-4.2081";
    version = "4.2081";
    addonId = "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4884091/youtube_addon-4.2081.xpi";
    sha256 = "18e34f9e811caaa94517f1746d41b34e72a4b2aa5d44b9eda6f6d952ca60d0b4";
  };

  untrapForYouTube = mkAddon {
    name = "untrap-for-youtube-10.4.1";
    version = "10.4.1";
    addonId = "{2662ff67-b302-4363-95f3-b050218bd72c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4939690/untrap_for_youtube-10.4.1.xpi";
    sha256 = "9d211625a3880581ecc109e64c9c212feecb3583177933f360902709d1aaddb9";
  };
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
      extensions.packages =
        with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
        [
          ublock-origin
          purpleadblock
          dearrow
          vimium
          privacy-badger
        ]
        ++ [
          onepassword
          improvedTube
          untrapForYouTube
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
