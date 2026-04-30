{
  config,
  pkgs,
  lib,
  ...
}:

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

    initContent = lib.mkBefore ''
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local

      if [[ -z "$TMUX" ]]; then
        SESSION_NAME="$$"
        tmux new-session -d -s "$SESSION_NAME" 2>/dev/null
        exec tmux attach -t "$SESSION_NAME"
      fi

      PROMPT="[%n@%F{red}%m%f %1~] "

      function gcap() {
        git add . && git commit -m "$*" && git push
      }

    '';

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
