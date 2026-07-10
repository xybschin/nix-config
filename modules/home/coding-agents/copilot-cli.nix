{
  lib,
  pkgs,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
in
{
  home = {
    packages = [ pkgs.github-copilot-cli ];
    shellAliases.cop = "copilot";
    file = {
      ".copilot/config.json".source = jsonFormat.generate "copilot-config.json" {
        autoUpdate = false;
        includeCoAuthoredBy = false;
      };
      ".copilot/mcp-config.json".source = jsonFormat.generate "copilot-mcp-config.json" {
        mcpServers.nixos = {
          type = "local";
          command = lib.getExe pkgs.mcp-nixos;
          args = [ ];
          tools = [ "*" ];
        };
      };
    };
  };
}
