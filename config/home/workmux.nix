{ ... }:
{
  config.my.features.home.workmux =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      home.packages = [
        inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home.shellAliases.wm = "workmux";
    };
}
