{ ... }:
{
  config.my.features.home.dotnet =
    { pkgs, ... }:
    let
      # One combined host, so `dotnet --list-sdks/--list-runtimes` sees
      # everything and DOTNET_ROOT has a single place to point at.
      dotnet = import ../_lib/dotnet.nix { inherit pkgs; };
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
