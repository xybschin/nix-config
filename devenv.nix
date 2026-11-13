{ pkgs, lib, ... }:
{
  packages = with pkgs; [
    git
    gnumake
    lua-language-server
    nil
    nixfmt
    nixfmt-tree
    sops
  ];

  # mcp-nixos is a Python application. Listing it in `packages` leaks its
  # PYTHONPATH (MCP SDK 1.x) into the shell, shadowing nixpkgs' mcp-server-git
  # (SDK 2.x) and crashing it on startup. A script puts only the executable on
  # PATH and keeps the shell's environment python-free.
  scripts.mcp-nixos.exec = "${lib.getExe pkgs.mcp-nixos} \"$@\"";
}
