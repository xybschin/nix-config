{ ... }:
{
  config.my.features.darwin.common =
    {
      pkgs,
      hostUser,
      ...
    }:
    {
      time.timeZone = "Europe/Berlin";

      nixpkgs.config.allowUnfree = true;

      nix = {
        package = pkgs.nix;
        settings = {
          # cache.nixos.org and its key come from nix-darwin's defaults; only
          # the trusted users and the CLI features are set here.
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
