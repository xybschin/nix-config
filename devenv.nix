{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    gnumake
    lua-language-server
    nil
    nixfmt
    nixfmt-tree
    sops
    mcp-nixos
  ];
}
