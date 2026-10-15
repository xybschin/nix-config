{ ... }:
{
  config.my.features.home.dotnet =
    { pkgs, ... }:
    let
      # One combined host, so `dotnet --list-sdks/--list-runtimes` sees
      # everything and DOTNET_ROOT has a single place to point at.
      dotnet = with pkgs.dotnetCorePackages; combinePackages [
        sdk_11_0
        sdk_10_0
      ];
    in
    {
      home.packages = [ dotnet ];

      home.sessionVariables = {
        DOTNET_ROOT = "${dotnet}/share/dotnet";
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      };

      home.sessionPath = [ "$HOME/.dotnet/tools" ];
    };
}
