{
  config.my.features.nixos.brave-browser = { ... }: {
    environment.etc."brave/policies/managed/extensions.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "enamippconapkdmgfgjchkhakpfinmaj;https://clients2.google.com/service/update2/crx" # DeArrow
        "dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx" # Vimium
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp;https://clients2.google.com/service/update2/crx" # Privacy Badger
        "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx" # 1Password
        "enboaomnljigfhfjfoalacienlhjlfil;https://clients2.google.com/service/update2/crx" # UnTrap for YouTube
      ];
    };
  };
}
