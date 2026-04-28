{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [ github-copilot-cli ];
  home.shellAliases.co = "copilot";
}
