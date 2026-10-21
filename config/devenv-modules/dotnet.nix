{ ... }:
{
  # Shared dotnet stack for per-project devenv shells. Import from a
  # project's devenv.nix via `imports = [ inputs.nix-config.devenvModules.dotnet ];`
  config.my.devenvModules.dotnet =
    { pkgs, ... }:
    {
      languages.dotnet = {
        enable = true;
        # One combined SDK host, same versions as the home feature
        # (config/home/dotnet.nix), via config/_lib/dotnet.nix.
        package = import ../_lib/dotnet.nix { inherit pkgs; };
      };
      env.DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    };
}
