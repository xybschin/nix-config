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
            args = [ "-y" "firecrawl-mcp" ];
            tools = [ "*" ];
          };
        };
      };
    };
  };
}
