{ ... }:
{
  config.my.features.home.devenv =
    { pkgs, ... }:
    {
      # The CLI that enters this repo's own shell (`.envrc` -> `use devenv`,
      # tool list in `devenv.nix`). Projects other than this repo do not need it.
      home.packages = [ pkgs.devenv ];
    };
}
