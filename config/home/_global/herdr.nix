{
  config,
  pkgs,
  inputs,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;
in

{
  programs.herdr = {
    enable = true;
    package = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
        hide_tab_bar_when_single_tab = true;
        sidebar_start_collapsed = true;
      };

      theme = {
        custom = {
          # Backgrounds & Surfaces
          panel_bg = c.base00; # #101010 (palette.bg)
          surface0 = c.base01; # #272727 (palette.line)
          surface1 = c.base02; # #474747 (palette.dim)
          surface_dim = c.base01; # #272727 (palette.line)

          # Text & Overlays
          text = c.base05; # #b0b0b0 (palette.fg)
          subtext0 = c.base04; # #777777 (palette.keyword / type / operator)
          overlay0 = c.base02; # #50585d (palette.comment)
          overlay1 = c.base04; # #777777 (palette.keyword)

          # Active Focus
          accent = c.base02; # #ffffff (palette.emphasis / border / func / string)

          # Diagnostics & Accent Colors
          yellow = c.base0A; # #d9ba73 (palette.const / warning)
          peach = c.base09; # #ff5733 (palette.orange)
          red = c.base08; # #ff7676 (palette.danger)
          green = c.base0B; # #86cd82 (palette.success)
          blue = c.base0D; # #458ee6 (palette.highlight)
          teal = c.base0C; # #5abfb5 (palette.cyan)
          mauve = c.base0E; # #f2a4db (palette.pink)
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
