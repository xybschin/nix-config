{
  pkgs,
  user,
  ...
}:

{
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings = {
      substituters = [
        "https://claude-code.cachix.org"
        "https://hyprland.cachix.org"
        "https://xybschin.cachix.org"
      ];
      trusted-public-keys = [
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        "xybschin.cachix.org-1:Vx/oBQ8RM8ZGhMWEheZvKg75UeB9G2PjitgDIUQ+tYo="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [
        "root"
        user
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  programs.zsh.enable = true;

  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
  };
}
