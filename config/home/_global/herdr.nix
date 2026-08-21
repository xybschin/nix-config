{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;
in
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
        tab_bar_position = "bottom";
        status_indicators = "symbols";
        tab_bar_right = [
          { type = "hostname"; }
          {
            type = "datetime";
            format = "%Y-%m-%d %H:%M";
          }
        ];
        tab_bar_right_separator = " · ";
      };

      theme = {
        name = "terminal";
        custom = {
          sidebar_bg = "${c.base00}";
          panel_bg = "${c.base00}";
          active_row_bg = "${c.base01}";
          selection_bg = "${c.base02}";
          accent = "${c.base0C}";
          green = "${c.base0B}";
          blue = "${c.base0D}";
          red = "${c.base08}";
          yellow = "${c.base0A}";
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
        close_pane = "prefix+c";
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
