{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  vscodeDir = "${configRoot}/modules/home-manager/vscode";
  vscodeWithPasswordStore = pkgs.vscode.override {
    commandLineArgs = "--password-store=gnome-libsecret";
  };
in
{
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${vscodeDir}/settings.json";

  home.packages = [ vscodeWithPasswordStore ];
}
