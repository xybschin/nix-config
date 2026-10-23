{ ... }:
{
  config.my.features.nixos.common =
    {
      pkgs,
      hostUser,
      inputs,
      configRoot,
      ...
    }:
    let
      localCaDir = "${configRoot}/certs/local";
      localCaFiles =
        if builtins.pathExists localCaDir then
          map (
            name:
            builtins.path {
              path = builtins.toPath "${localCaDir}/${name}";
              name = "local-ca-${name}";
            }
          ) (
            builtins.filter (name: builtins.match ".*\\.(crt|pem)" name != null) (
              builtins.attrNames (builtins.readDir localCaDir)
            )
          )
        else
          [ ];
    in
    {
      imports = [
        inputs.stylix.nixosModules.stylix
        { stylix.overlays.enable = false; }
      ];

      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_GB.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
      };

      nixpkgs.config.allowUnfree = true;

      nix = {
        package = pkgs.nix;
        settings = {
          trusted-users = [ "root" ] ++ [ hostUser ];

          substituters = [
            "https://cache.nixos.org/"
            "https://nix-community.cachix.org"
            "https://xybschin.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "xybschin.cachix.org-1:Vx/oBQ8RM8ZGhMWEheZvKg75UeB9G2PjitgDIUQ+tYo="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };

      # Optional host-local trust anchors are folded into security.pki.caBundle,
      # which the Nix daemon exposes to its network clients.
      security.pki.certificateFiles = localCaFiles;

      fonts.fontconfig = {
        enable = true;
        hinting = {
          enable = true;
          style = "slight";
        };
        antialias = true;
        subpixel.rgba = "rgb";
      };

      environment.localBinInPath = true;
      environment.systemPackages = [ pkgs.mcp-nixos ];
      programs.zsh.enable = true;
      programs.nix-ld.enable = true;

      system.stateVersion = "25.11";
    };
}
