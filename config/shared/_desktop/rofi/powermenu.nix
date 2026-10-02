{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  rgba = hex: alpha: "#${hex}${alpha}";

  # Glyphs bundled with the JetBrainsMono Nerd Font (Font Awesome codepoints),
  # field 0 of each row is the icon, field 1 is the label shown in the message bar.
  entries = pkgs.writeShellScript "rofi-powermenu-entries" ''

    shutdown='󰐥'
    reboot='󰜉'
    lock=''
    logout='󰍃'

    if [ -z "$1" ]; then
        printf '%s\0Shutdown\n%s\0Reboot\n%s\0Lock screen\n%s\0Log out\n%s\0Cancel\n' \
            "$shutdown" "$reboot" "$lock" "$logout" "$cancel"
    else
        case "$1" in
            "$shutdown") hyprshutdown --post-cmd 'poweroff' ;;
            "$reboot")   hyprshutdown --post-cmd 'reboot' ;;
            "$lock")     hyprlock ;;
            "$logout")   hyprctl dispatch 'hl.dsp.exit()' ;;
            *)           exit 0 ;;
        esac
    fi
  '';

  powermenu = pkgs.writeShellApplication {
    name = "rofi-powermenu";
    runtimeInputs = [ pkgs.rofi ];
    text = ''
      rofi \
        -modes "powermenu:${entries}" \
        -show powermenu \
        -theme koda-power \
        -no-custom
    '';
  };

  theme = ''
    configuration {
      show-icons:        false;
    }

    * {
        /* Geometry */
        box-spacing:       14px;
        box-margin:        20px;
        inputbar-spacing:  0px;
        list-spacing:      14px;
        general-padding:   10px 20px;
        general-radius:    12px;
        element-padding:   24px 20px;
        element-radius:    16px;
        element-font:      "JetBrainsMono Nerd Font 24";

        /* Palette (base16) */
        background:        ${rgba c.base00 "FF"};
        background-alt:    ${rgba c.base01 "FF"};
        foreground:        ${rgba c.base08 "FF"};
        foreground-dim:    ${rgba c.base04 "FF"};
        selected:          ${rgba c.base05 "FF"};
        urgent:            ${rgba c.base0F "FF"};
        active:            ${rgba c.base0A "FF"};

        font:              "JetBrainsMono Nerd Font 11";
    }

    window {
        transparency:      "real";
        location:          center;
        anchor:            center;
        width:             620px;
        margin:            0px;
        padding:           0px;
        border:            1px;
        border-radius:     0px;
        border-color:      @background-alt;
        background-color:  @background;
    }

    mainbox {
        enabled:           true;
        spacing:           var(box-spacing);
        margin:            0px;
        padding:           var(box-margin);
        border:            0px solid;
        border-color:      @selected;
        background-color:  transparent;
        children:          [ listview ];
    }

    dummy {
        background-color:  transparent;
    }

    textbox-prompt-colon {
        enabled:           true;
        expand:            false;
        str:               "SYSTEM";
        padding:           var(general-padding);
        border-radius:     var(general-radius);
        background-color:  @urgent;
        text-color:        @background;
        font:              "JetBrainsMono Nerd Font 13";
    }

    prompt {
        enabled:           true;
        padding:           var(general-padding);
        border-radius:     var(general-radius);
        background-color:  @active;
        text-color:        @background;
        font:              "JetBrainsMono Nerd Font 13";
    }

    message {
        enabled:           true;
        margin:            0px;
        padding:           var(general-padding);
        border:            0px;
        border-radius:     var(general-radius);
        border-color:      @selected;
        background-color:  @background-alt;
        text-color:        @foreground;
        font:              "JetBrainsMono Nerd Font 15";
    }

    textbox {
        background-color:  inherit;
        text-color:        inherit;
        vertical-align:    0.5;
        horizontal-align:  0.0;
        placeholder-color: @foreground-dim;
        blink:             false;
        markup:            true;
    }

    error-message {
        padding:           var(general-padding);
        border:            0px solid;
        border-radius:     var(general-radius);
        border-color:      @selected;
        background-color:  @background;
        text-color:        @foreground;
    }

    listview {
        enabled:           true;
        columns:           4;
        lines:             1;
        cycle:             true;
        dynamic:           true;
        scrollbar:         false;
        layout:            vertical;
        reverse:           false;
        fixed-height:      true;
        fixed-columns:     true;
        spacing:           var(list-spacing);
        margin:            0px;
        padding:           0px;
        border:            0px solid;
        border-radius:     0px;
        border-color:      @selected;
        background-color:  transparent;
        text-color:        @foreground;
        cursor:            "default";
    }

    element {
        enabled:           true;
        spacing:           0px;
        margin:            0px;
        padding:           var(element-padding);
        border:            0px solid;
        border-radius:     var(element-radius);
        border-color:      @selected;
        background-color:  @background-alt;
        text-color:        @foreground;
        cursor:            pointer;
    }

    element-text {
        font:              var(element-font);
        background-color:  transparent;
        text-color:        inherit;
        cursor:            inherit;
        vertical-align:    0.5;
        horizontal-align:  0.5;
    }

    element selected.normal {
        background-color:  var(selected);
        text-color:        var(background);
    }
  '';
in
{
  xdg.dataFile."rofi/themes/koda-power.rasi".text = theme;

  home.packages = [ powermenu ];
}
