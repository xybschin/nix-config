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
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    history = {
      size = 50000;
      save = 50000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "tmux"
      ];
      extraConfig = "";
    };

    initContent = lib.mkBefore ''
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local

      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOQUIT=true

      PROMPT="[%n@%F{red}%m%f %1~] "
      setopt INC_APPEND_HISTORY_TIME
      source <(fzf --zsh)
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
