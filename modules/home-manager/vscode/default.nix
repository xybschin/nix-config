{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  vscodeDir = "${configRoot}/modules/home-manager/vscode";
in
{
  # Symlink settings.json so edits to the file in the repo are reflected immediately.
  # Linux (Code):     ~/.config/Code/User/settings.json
  # Linux (Codium):   ~/.config/VSCodium/User/settings.json
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${vscodeDir}/settings.json";

  # Uncomment if you use VSCodium instead:
  # xdg.configFile."VSCodium/User/settings.json".source =
  #   config.lib.file.mkOutOfStoreSymlink "${vscodeDir}/settings.json";
}
