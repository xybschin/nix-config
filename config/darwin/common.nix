{ ... }:
{
  config.my.features.darwin.common = {
    pkgs,
    hostUser,
    ...
  }: {
    time.timeZone = "Europe/Berlin";

    nixpkgs.config.allowUnfree = true;

    nix = {
      package = pkgs.nix;
      settings = {
        substituters = [ "https://claude-code.cachix.org" ];
        trusted-public-keys = [
          "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        ];
        trusted-users = [ "root" ] ++ [ hostUser ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    programs.zsh.enable = true;

    security.pam.services.sudo_local.touchIdAuth = true;

    homebrew = {
      enable = true;
      onActivation.cleanup = "zap";
    };
  };
}
