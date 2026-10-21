{ pkgs, lib, ... }:
{
  packages = with pkgs; [
    git
    gnumake
    nil
    nixfmt
    sops
    mcp-nixos
  ];

  # Project-scoped MCP servers; generates .mcp.json for Claude Code.
  # opencode reads the same server from .opencode/opencode.json.
  claude.code.enable = true;
  claude.code.mcpServers.nixos = {
    type = "stdio";
    command = lib.getExe pkgs.mcp-nixos;
  };
}
