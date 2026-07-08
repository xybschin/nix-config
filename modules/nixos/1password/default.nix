{
  config,
  lib,
  ...
}:

{
  options.my."1password".enable = lib.mkEnableOption "1Password";

  config = lib.mkIf config.my."1password".enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = builtins.attrNames config.snowfallorg.users;
    };

    environment = {
      etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            zen-bin
            zen
          '';
          mode = "0755";
        };
      };
    };
  };
}
