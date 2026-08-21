{
  pkgs,
  ...
}:

{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;

      terminal = {
        default_shell = "${pkgs.zsh}/bin/zsh";
        shell_mode = "login";
        new_cwd = "follow";
      };

      ui = {
        tab_bar_position = "top";
        pane_gaps = false;
        pane_scrollbars = false;
        sidebar_collapsed_mode = "hidden";
      };

      theme = {
        name = "terminal";
        custom = {
          panel_bg = "#101010";
          sidebar_bg = "#101010";
          active_row_bg = "#272727";
          selection_bg = "#272727";
          surface0 = "#272727";
          surface1 = "#474747";
          overlay0 = "#50585d";
          overlay1 = "#777777";
          text = "#b0b0b0";
          subtext0 = "#777777";
          accent = "#d9ba73";
          green = "#86cd82";
          blue = "#8ebeec";
          red = "#ff7676";
          yellow = "#d9ba73";
        };
      };

      keys = {
        prefix = "ctrl+b";
        focus_pane_left = [
          "prefix+h"
          "ctrl+alt+h"
        ];
        focus_pane_down = [
          "prefix+j"
          "ctrl+alt+j"
        ];
        focus_pane_up = [
          "prefix+k"
          "ctrl+alt+k"
        ];
        focus_pane_right = [
          "prefix+l"
          "ctrl+alt+l"
        ];
        previous_tab = [
          "prefix+H"
          "prefix+p"
        ];
        next_tab = [
          "prefix+L"
          "prefix+n"
        ];
        new_tab = [
          "prefix+c"
          "prefix+ctrl+c"
        ];
        close_pane = "prefix+x";
        split_vertical = "prefix+v";
        split_horizontal = "prefix+s";
        zoom = "prefix+z";
        copy_mode = [
          "prefix+["
          "ctrl+space"
          "prefix+enter"
        ];
        goto = [
          "prefix+g"
          "prefix+f"
        ];
        switch_tab = "prefix+1..9";
      };
    };
  };

  home.shellAliases.hd = "herdr";
}
