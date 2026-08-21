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

    initContent = lib.mkBefore ''
      bindkey '^H' backward-kill-word

      [ -f ~/.zshrc.local ] && source ~/.zshrc.local

      if [[ -z "$HERDR_PANE_ID" && -z "$TMUX" && -o interactive ]]; then
        exec herdr
      fi

      PROMPT="[%n@%F{${c.base09}}%m%f %1~] "

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
