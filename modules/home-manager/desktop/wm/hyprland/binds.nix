{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # Mouse bindings.
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    binde = [
      ", XF86AudioRaiseVolume, exec, pulsemixer --change-volume +2"
      ", XF86AudioLowerVolume, exec, pulsemixer --change-volume -2"
      ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
      ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      "$mod ALT, k, exec, pulsemixer --change-volume +5"
      "$mod ALT, j, exec, pulsemixer --change-volume -5"
    ];

    bind = [
      "$mod CTRL, s, exec, hyprshutdown --post-cmd 'poweroff'"
      "$mod CTRL, r, exec, hyprshutdown --post-cmd 'reboot'"

      # Window/Session actions.
      "$mod, C, killactive,"
      "$mod, F, fullscreen,"
      "$mod, T, togglefloating,"
      "$mod, M, exit,"

      # Dwindle
      "$mod, O, togglesplit,"
      "$mod, P, pseudo,"

      # Lock screen
      "$mod, Escape, exec, hyprlock"

      # Screenshots (hyprshot)
      "$mod SHIFT, W, exec, hyprshot -m window"
      "$mod SHIFT, R, exec, hyprshot -m region"

      # Application shortcuts.
      "$mod, Q, exec, ghostty"
      "$mod, R, exec, rofi -show drun"
      "$mod, E, exec, ghostty -e ranger ~"
      "$mod SHIFT, d, exec, $HOME/.config/rofi/scripts/rofi-monitor-menu"

      # Special workspace
      "$mod, S, togglespecialworkspace"
      "$mod SHIFT, S, movetoworkspacesilent, special"

      # Move window focus with vim keys.
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, k, movefocus, u"
      "$mod, j, movefocus, d"

      # Swap windows with vim keys
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, l, movewindow, r"
      "$mod SHIFT, k, movewindow, u"
      "$mod SHIFT, j, movewindow, d"

      "$mod SHIFT, c, centerwindow, 1"

      # Move monitor focus.
      "$mod, TAB, focusmonitor, +1"

      # Switch workspaces.
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # Move active window to a workspace.
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      "$mod CTRL SHIFT, l, movetoworkspace, r+1"
      "$mod SHIFT, Right, movetoworkspace, r+1"
      "$mod CTRL SHIFT, h, movetoworkspace, r-1"
      "$mod SHIFT, Left, movetoworkspace, r-1"
    ];
  };
}
