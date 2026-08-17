{
  lib,
  pkgs,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  initialConfig = jsonFormat.generate "copilot-config.json" {
    autoUpdate = false;
    includeCoAuthoredBy = false;
  };
  mcpConfig = jsonFormat.generate "copilot-mcp-config.json" {
    mcpServers = {
      git = {
        type = "local";
        command = lib.getExe pkgs.mcp-server-git;
        args = [ ];
        tools = [ "*" ];
      };
      nixos = {
        type = "local";
        command = lib.getExe pkgs.mcp-nixos;
        args = [ ];
        tools = [ "*" ];
      };
      firecrawl = {
        type = "local";
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "firecrawl-mcp"
        ];
        tools = [ "*" ];
      };
    };
  };
in
{
  home = {
    packages = [ pkgs.github-copilot-cli ];
    shellAliases.cop = "copilot";
    file = {
      ".copilot/mcp-config.json".source = mcpConfig;
    };
  };

  home.activation.generateCopilotConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    copilotDir="$HOME/.copilot"
    configFile="$copilotDir/config.json"
    mkdir -p "$copilotDir"
    if [ -f "$configFile" ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$configFile" ${initialConfig} > "$configFile.tmp" &&
        mv "$configFile.tmp" "$configFile"
    else
      cp --no-preserve=mode ${initialConfig} "$configFile"
      chmod 644 "$configFile"
    fi
  '';
}
