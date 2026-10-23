{ ... }:
{
  config.my.features.home."shared.vscode" =
    { pkgs, ... }:
    let
      # NOTE: do not wrap this in `pkgs.vscode-with-extensions`. That wrapper
      # hard-codes `--extensions-dir` to its own (empty) extension store path,
      # which makes VS Code ignore the extensions Home Manager links into
      # `~/.vscode/extensions`.
      vscodeWithPasswordStore = pkgs.vscode.override {
        commandLineArgs = "--password-store=gnome-libsecret";
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
