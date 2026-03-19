{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 1000000;
    escapeTime = 0;
    terminal = "screen-256color";
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-fzf
    ];

    extraConfig = ''
      ${builtins.readFile ./tmux.conf}
      run-shell ${pkgs.tmuxPlugins.fzf-tmux-url}/share/tmux-plugins/fzf-tmux-url/fzf-url.tmux
      run-shell ${pkgs.tmuxPlugins.mode-indicator}/share/tmux-plugins/mode-indicator/mode_indicator.tmux
    '';
  };
}
