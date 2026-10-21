{ ... }:
{
  config.my.features.home."shared.vscode" =
    { pkgs, ... }:
    let
      vscodeWithPasswordStore = pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscode.override {
          commandLineArgs = "--password-store=gnome-libsecret";
        };
      };
    in
    {
      programs.vscode = {
        enable = true;
        package = vscodeWithPasswordStore;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            vscodevim.vim
            bbenoist.nix
            davidseptimus.armada-theme
            catppuccin.catppuccin-vsc-icons
          ];
          userSettings = import ./_vscode/settings.nix;
        };
      };
    };
}
