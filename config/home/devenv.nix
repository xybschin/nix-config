{ ... }:
{
  config.my.features.home.devenv =
    { pkgs, ... }:
    {
      # Per-project dev shells (`devenv init` in a project). Shared language
      # defaults are exported by this flake as devenvModules (see
      # config/devenv-modules/).
      home.packages = [ pkgs.devenv ];
    };
}
