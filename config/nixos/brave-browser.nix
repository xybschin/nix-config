{ ... }:
let
  updateUrl = "https://clients2.google.com/service/update2/crx";

  ids = {
    dearrow = "enamippconapkdmgfgjchkhakpfinmaj";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    privacy-badger = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";
    onepassword = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
    untrap = "enboaomnljigfhfjfoalacienlhjlfil";
  };

in
{
  config.my.features.nixos.brave-browser =
    {
      config,
      inputs,
      lib,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age.keyFile = "/var/lib/sops-nix/key.txt";
        secrets.dearrow_api_key = { };
      };

      sops.templates."brave-extension-settings.json" = {
        mode = "0444";
        content = builtins.toJSON {
          "3rdparty".extensions = {
            ${ids.privacy-badger} = {
              showIntroPage = false;
              showCounter = false;
              learnLocally = true;
            };
            ${ids.dearrow}.licenseKey = config.sops.placeholder.dearrow_api_key;
          };
        };
      };

      environment.etc = {
        "brave/policies/managed/extensions.json".text = builtins.toJSON {
          ExtensionInstallForcelist = lib.mapAttrsToList (_: id: "${id};${updateUrl}") ids;
        };
        "brave/policies/managed/extension-settings.json".source =
          config.sops.templates."brave-extension-settings.json".path;

        "brave/policies/managed/debullshitinator.json".text = builtins.toJSON {
          BraveRewardsDisabled = true;
          BraveWalletDisabled = true;
          BraveVPNDisabled = 1;
          BraveAIChatEnabled = false;
          NewTabPageLocation = "https://duckduckgo.com";
          TorDisabled = true;
          PasswordManagerEnabled = false;
          DnsOverHttpsMode = "automatic";
          TranslateEnabled = false;
          AutoFillAddressEnabled = false;
        };
      };
    };
}
