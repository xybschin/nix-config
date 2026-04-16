{
  pkgs,
  lib,
  config,
  ...
}:
let
  providersFilePath = "${config.home.homeDirectory}/claude-code-providers.json";
in
{
  home.packages = with pkgs; [ claude-code ];
  home.shellAliases.cc = "claude";

  programs.claude-code = {
    enable = true;
    settings = lib.mkMerge [
      (lib.mkIf (builtins.pathExists providersFilePath) {
        provider = builtins.fromJSON (builtins.readFile providersFilePath);
      })
    ];
  };
}
