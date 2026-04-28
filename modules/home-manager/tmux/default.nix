{
  config,
  pkgs,
  ...
}:
let
  tmuxModeIndicatorConfig = ''
    set -g @mode_indicator_prefix_prompt ' TMUX '
    set -g @mode_indicator_copy_prompt ' COPY '
    set -g @mode_indicator_sync_prompt ' SYNC '
    set -g @mode_indicator_empty_prompt ' NORM '
    set -g @mode_indicator_prefix_mode_style 'bg=red,fg=black'
    set -g @mode_indicator_copy_mode_style 'bg=#d9ba73,fg=black'
    set -g @mode_indicator_sync_mode_style 'bg=red,fg=black'
    set -g @mode_indicator_empty_mode_style 'bg=#272727,fg=#777777'
    run-shell ${pkgs.tmuxPlugins.mode-indicator}/share/tmux-plugins/mode-indicator/mode_indicator.tmux
  '';

  bindings = ''
    unbind-key -a

    bind-key -T find-table w run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/window.sh switch"
    bind-key -T find-table s run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh switch"
    bind-key -T find-table q switch-client -T root
    bind-key f switch-client -T find-table

    bind ^C new-window -c "$HOME"
    bind R source-file ${config.xdg.configHome}/tmux/tmux.conf

    bind 0 select-window -t :0
    bind 1 select-window -t :1
    bind 2 select-window -t :2
    bind 3 select-window -t :3
    bind 4 select-window -t :4
    bind 5 select-window -t :5
    bind 6 select-window -t :6
    bind 7 select-window -t :7
    bind 8 select-window -t :8
    bind 9 select-window -t :9

    bind H previous-window
    bind L next-window
    bind ^A last-window

    bind z resize-pane -Z
    bind l refresh-client

    bind s split-window -v
    bind v split-window -h
    bind s split-window -v -c "#{pane_current_path}"
    bind v split-window -h -c "#{pane_current_path}"

    bind-key -n C-M-h select-pane -L
    bind-key -n C-M-j select-pane -D
    bind-key -n C-M-k select-pane -U
    bind-key -n C-M-l select-pane -R

    bind : command-prompt
    bind * setw synchronize-panes
    bind P set pane-border-status
    bind c kill-pane
    bind x swap-pane -D

    bind Enter copy-mode
    bind-key -n ^space copy-mode
    bind-key -T copy-mode-vi v send-keys -X begin-selection

    set -g @fzf-url-bind 'x'
  '';

  options = ''
    set-option -g terminal-overrides ',xterm-256color:Tc'
    set-option -g set-titles on
    set-option -g set-titles-string "#W"
    set-option -g remain-on-exit off

    set -g set-clipboard on
    set -g pane-base-index 1
    set -g status on
    set -g status-interval 1
    set -g status-left-length 100
    set -g status-right-length 100
    set -g status-position bottom
    set -g status-style "fg=red,bg=#101010"
    set -g status-left '#{tmux_mode_indicator}#[bg=green]#[fg=black] #{user}@#H #[fg=#{@LGRAY} #[bg=magenta]#[fg=black]'
    set -g status-right '#[fg=green]%Y-%m-%d #[fg=#ffffff]%H:%M'
    set -g status-justify absolute-centre
    set -g @prefix_highlight_output_prefix "#[fg=#252530]#[bg=#d9ba73]"
    set -g @prefix_highlight_output_suffix ""

    setw -g window-status-separator " - "
    setw -g window-status-format "#[fg=#777777,bg=#272727] #I #[fg=#777777,bg=black] #W "
    setw -g window-status-current-format "#[fg=black,bg=red] #I #[fg=#ffffff,bg=black] #W "
  '';

  hooks = ''
    set-hook -g client-detached 'if -F "#{==:#{session_attached},0}" "run-shell \"tmux kill-session -t #{session_name}\""'
  '';
in
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 1000000;
    escapeTime = 0;
    terminal = "tmux-256color";
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-fzf
      fzf-tmux-url
    ];

    extraConfig = ''
      ${options}
      ${bindings}
      ${hooks}
      ${tmuxModeIndicatorConfig}
    '';
  };
}
