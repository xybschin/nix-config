{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  vscodeDir = "${configRoot}/modules/shared/vscode";
  vscodeWithPasswordStore = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscode.override {
      commandLineArgs = "--password-store=gnome-libsecret";
    };
    vscodeExtensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
in
{
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${vscodeDir}/settings.json";

  home.packages = [ vscodeWithPasswordStore ];
}
