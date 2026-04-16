{ pkgs, ... }:
{
  home.packages = with pkgs; [ claude-code ];
  home.shellAliases.cc = "claude";

  programs.claude-code = {
    enabale = true;
  };
}
