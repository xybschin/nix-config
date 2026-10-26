{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    gnumake
    lua-language-server
    nil
    nixfmt
    sops
    mcp-nixos
  ];
}
