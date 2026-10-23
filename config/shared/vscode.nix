{ ... }:
{
  config.my.features.home."shared.vscode" =
    { config, pkgs, ... }:
    let
      fonts = config.stylix.fonts;

      # Stylix's factor for pt -> px, plus the ratios it uses for the
      # secondary font sizes.
      px = fonts.sizes.terminal * 4.0 / 3.0;

      vscodeWithPasswordStore = pkgs.vscode.override {
        commandLineArgs = "--password-store=gnome-libsecret";
      };
    in
    {
      # NOTE: do not wrap this in `pkgs.vscode-with-extensions`. That wrapper
      # hard-codes `--extensions-dir` to its own (empty) extension store path,
      # which makes VS Code ignore the extensions Home Manager links into
      # `~/.vscode/extensions`.

      # Stylix's VS Code target writes `workbench.colorTheme = "Stylix"`, which
      # cannot be overridden per key. Theme VS Code here and mirror Stylix's
      # font settings below instead (same approach as tmux, waybar).
      stylix.targets.vscode.enable = false;

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
          userSettings = (import ./_vscode/settings.nix) // {
            # Installing an extension is not enough — VS Code only activates a
            # theme when the setting names one of the ids the extension
            # contributes.
            "workbench.colorTheme" = "Armada";
            "workbench.iconTheme" = "catppuccin-mocha";

            "editor.fontFamily" = fonts.monospace.name;
            "editor.inlayHints.fontFamily" = fonts.monospace.name;
            "editor.inlineSuggest.fontFamily" = fonts.monospace.name;
            "scm.inputFontFamily" = fonts.monospace.name;
            "debug.console.fontFamily" = fonts.monospace.name;
            "chat.editor.fontFamily" = fonts.monospace.name;
            "markdown.preview.fontFamily" = fonts.sansSerif.name;
            "chat.fontFamily" = fonts.sansSerif.name;
            "notebook.markup.fontFamily" = fonts.sansSerif.name;

            "editor.fontSize" = px;
            "debug.console.fontSize" = px;
            "markdown.preview.fontSize" = px;
            "terminal.integrated.fontSize" = px;
            "chat.editor.fontSize" = px;
            "editor.minimap.sectionHeaderFontSize" = px * 9.0 / 14.0;
            "scm.inputFontSize" = px * 13.0 / 14.0;
            "screencastMode.fontSize" = px * 56.0 / 14.0;
          };
        };
      };
    };
}
