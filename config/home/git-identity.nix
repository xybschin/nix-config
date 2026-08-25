{ ... }:
{
  config.my.features.home.git-identity = { ... }: {
    programs.git = {
      enable = true;
      settings = {
        user.name = "xybschin";
        user.email = "hello@bjarneschindler.dev";
        extraConfig.credential.helper = "store";
        color.ui = true;
        init.defaultBranch = "main";
      };
    };
  };
}
