{
  config,
  pkgs,
  lib,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  home.packages = with pkgs; [
    uv
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
      ];
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        [ -f ~/.zshrc.local ] && source ~/.zshrc.local

        if [[ -z "$TMUX" && -o interactive ]]; then
          SESSION_NAME="$$"
          tmux new-session -d -s "$SESSION_NAME" 2>/dev/null
          exec tmux attach -t "$SESSION_NAME"
        fi

        if [ -n "$TMUX" ]; then
          tmux set-environment -g PATH "$PATH" >/dev/null 2>&1
        fi

        PROMPT="[%n@%F{${c.base09}}%m%f %1~] "

        function gcap() {
          git add . && git commit -m "$*" && git push
        }

      '')
      (lib.mkAfter ''
        # Ctrl+Backspace across different terminals / multiplexers
        for keymap in emacs viins; do
          bindkey -M "$keymap" '^H' backward-kill-word
          bindkey -M "$keymap" '^_' backward-kill-word
          bindkey -M "$keymap" '^[[3;5~' backward-kill-word
          bindkey -M "$keymap" '^[[8;5~' backward-kill-word
          bindkey -M "$keymap" '^[[127;5u' backward-kill-word
          bindkey -M "$keymap" '^[[127;5~' backward-kill-word
        done
      '')
    ];

    shellAliases = {
      lat = "tree";
      la = "ls -al";
      ll = "ls -l";
      gc = "git commit";
      gu = "git push";
      gd = "git pull";
    };
  };
}
