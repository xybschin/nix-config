{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    gnumake
    nil
    nixfmt
    sops
    mcp-nixos
  ];
}
