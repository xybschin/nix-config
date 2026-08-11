{ ... }:
{
  config.my.features.nixos."1password" = { hostUser, ... }: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ hostUser ];
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen-bin
          zen
        '';
        mode = "0755";
      };
    };
  };
}
