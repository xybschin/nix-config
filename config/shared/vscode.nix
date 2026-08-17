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
      # Routed through `programs.vscode` so that stylix's vscode target activates:
      # it injects the "Stylix" color-theme extension plus font/color settings into
      # `programs.vscode.profiles.default` (see stylix/modules/vscode/each-config.nix).
      programs.vscode = {
        enable = true;
        package = vscodeWithPasswordStore;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            vscodevim.vim
          ];
          userSettings = import ./_vscode/settings.nix;
        };
      };
    };
}
