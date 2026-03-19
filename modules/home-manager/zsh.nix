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
        "tmux"
      ];
    };

    initContent = lib.mkBefore ''
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOQUIT=true
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
