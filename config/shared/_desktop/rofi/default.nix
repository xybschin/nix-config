{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  rgba = hex: alpha: "#${hex}${alpha}";

  powermenu = pkgs.writeShellScript "rofi-powermenu" ''
    shutdown=" Shutdown"
    reboot=" Reboot"
    lock=" Lock"
    logout=" Logout"

    if [ -z "$1" ]; then
        echo -e "$shutdown\n$reboot\n$lock\n$logout"
    else
        case "$1" in
            *Shutdown*) hyprshutdown --post-cmd 'poweroff' ;;
            *Reboot*)   hyprshutdown --post-cmd 'reboot' ;;
            *Lock*)     hyprlock ;;
            *Logout*)   hyprctl dispatch "hl.dsp.exit()" ;;
        esac
    fi
  '';

  theme = ''
    /**
     * Author : Aditya Shakya (adi1090x)
     * Github : @adi1090x
     **/

    /*****----- Configuration -----*****/
    configuration {
        modi:                       "drun,run,power:${powermenu}";
        show-icons:                 true;
        display-drun:               " Apps";
        display-run:                " Run";
        display-filebrowser:        " Files";
        display-window:             " Windows";
        display-power:              " Power";
        drun-display-format:        "{name}";
        drun-match-fields:          "name,generic";
        window-format:              "{w} · {c} · {t}";
    }

    /*****----- Global Properties -----*****/
    * {
        font:                        "${config.stylix.fonts.monospace.name} Bold 11";

        /* Muted Koda Dark Palette */
        background:                  ${rgba c.base00 "CC"}; 
        background-alt:              ${rgba c.base01 "CC"}; 
        selected-muted:              ${rgba c.base02 "1A"}; 
        foreground:                  ${rgba c.base04 "FF"}; 
        foreground-emphasis:         ${rgba c.base06 "FF"}; 
        accent-muted:                ${rgba c.base0A "FF"}; 
        urgent:                      ${rgba c.base08 "FF"}; 
        border:                      ${rgba c.base01 "AA"}; 

        border-colour:               var(border);
        handle-colour:               var(accent-muted);
        background-colour:           var(background);
        foreground-colour:           var(foreground);
        alternate-background:        var(background-alt);
        normal-background:           var(background);
        normal-foreground:           var(foreground);
        urgent-background:           var(urgent);
        urgent-foreground:           var(background);
        active-background:           var(selected-muted);
        active-foreground:           var(foreground-emphasis);
        
        /* Selection States: Low contrast & Muted */
        selected-normal-background:  var(selected-muted);
        selected-normal-foreground:  var(foreground-emphasis);
        
        selected-urgent-background:  var(urgent);
        selected-urgent-foreground:  var(background);
        selected-active-background:  var(selected-muted);
        selected-active-foreground:  var(foreground-emphasis);
        alternate-normal-background: var(background);
        alternate-normal-foreground: var(foreground);
        alternate-urgent-background: var(urgent);
        alternate-urgent-foreground: var(background);
        alternate-active-background: var(selected-muted);
        alternate-active-foreground: var(foreground-emphasis);
    }

    /*****----- Main Window -----*****/
    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       800px;
        x-offset:                    0px;
        y-offset:                    0px;

        enabled:                     true;
        margin:                      0px;
        padding:                     0px;
        border:                      1px solid;
        border-radius:               0px;
        border-color:                var(border-colour);
        cursor:                      "default";
        background-color:            var(background-colour);
    }

    /*****----- Main Box -----*****/
    mainbox {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     20px;
        background-color:            transparent;
        children:                    [ "inputbar", "message", "custombox" ];
    }

    /*****----- Custom Box -----*****/
    custombox {
        spacing:                     10px;
        background-color:            var(background-colour);
        text-color:                  var(foreground-colour);
        orientation:                 vertical;
        children:                    [ "mode-switcher", "listview" ];
        background-color:            transparent;
    }

    /*****----- Inputbar -----*****/
    inputbar {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     8px 12px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                var(border-colour);
        background-color:            transparent;
        text-color:                  var(foreground-colour);
        children:                    [ "textbox-prompt-colon", "entry" ];
    }

    prompt {
        enabled:                     true;
        background-color:            transparent;
        text-color:                  inherit;
    }
    textbox-prompt-colon {
        enabled:                     true;
        padding:                     5px 0px;
        expand:                      false;
        str:                         "";
        background-color:            inherit;
        text-color:                  inherit;
    }
    entry {
        enabled:                     true;
        padding:                     5px 0px;
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      text;
        placeholder:                 "Search...";
        placeholder-color:           inherit;
    }
    num-filtered-rows {
        enabled:                     true;
        expand:                      false;
        background-color:            inherit;
        text-color:                  inherit;
    }
    textbox-num-sep {
        enabled:                     true;
        expand:                      false;
        str:                         "/";
        background-color:            inherit;
        text-color:                  inherit;
    }
    num-rows {
        enabled:                     true;
        expand:                      false;
        background-color:            inherit;
        text-color:                  inherit;
    }
    case-indicator {
        enabled:                     true;
        background-color:            inherit;
        text-color:                  inherit;
    }

    /*****----- Listview -----*****/
    listview {
        enabled:                     true;
        columns:                     1;
        lines:                       8;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   true;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        
        spacing:                     5px;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                var(border-colour);
        background-color:            transparent;
        text-color:                  var(foreground-colour);
        cursor:                      "default";
    }
    scrollbar {
        handle-width:                5px;
        handle-color:                var(handle-colour);
        border-radius:               0px;
        background-color:            var(alternate-background);
    }

    /*****----- Elements -----*****/
    element {
        enabled:                     true;
        spacing:                     10px;
        margin:                      0px;
        padding:                     10px;
        border:                      0px solid;
        border-radius:               8px;
        border-color:                var(border-colour);
        background-color:            transparent;
        text-color:                  var(foreground-colour);
        cursor:                      pointer;
    }
    element normal.normal {
        background-color:            transparent;
        text-color:                  var(normal-foreground);
    }
    element normal.urgent {
        background-color:            var(urgent-background);
        text-color:                  var(urgent-foreground);
    }
    element normal.active {
        background-color:            var(active-background);
        text-color:                  var(active-foreground);
    }
    element selected.normal {
        background-color:            var(selected-normal-background);
        text-color:                  var(selected-normal-foreground);
    }
    element selected.urgent {
        background-color:            var(selected-urgent-background);
        text-color:                  var(selected-urgent-foreground);
    }
    element selected.active {
        background-color:            var(selected-active-background);
        text-color:                  var(selected-active-foreground);
    }
    element alternate.normal {
        background-color:            transparent;
        text-color:                  var(alternate-normal-foreground);
    }
    element alternate.urgent {
        background-color:            var(alternate-urgent-background);
        text-color:                  var(alternate-urgent-foreground);
    }
    element alternate.active {
        background-color:            var(alternate-active-background);
        text-color:                  var(alternate-active-foreground);
    }
    element-icon {
        background-color:            transparent;
        text-color:                  inherit;
        size:                        24px;
        cursor:                      inherit;
    }
    element-text {
        background-color:            transparent;
        text-color:                  inherit;
        highlight:                   inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:            0.0;
    }

    /*****----- Mode Switcher -----*****/
    mode-switcher {
        enabled:                     true;
        expand:                      false;
        orientation:                 horizontal;
        spacing:                     10px;
        margin:                      0px;
        padding:                     10px;
        border:                      0px solid;
        border-radius:               9px;
        border-color:                var(border-colour);
        background-color:            transparent;
        text-color:                  var(foreground-colour);
    }
    button {
        padding:                     8px 0px 8px 0px;
        border:                      0px solid;
        border-radius:               8px;
        border-color:                var(border-colour);
        background-color:            var(background);
        text-color:                  inherit;
        vertical-align:              0.0;
        horizontal-align:            0.5;
        cursor:                      pointer;
    }
    button selected {
        background-color:            var(alternate-background);
        text-color:                  var(selected-normal-foreground);
    }

    /*****----- Message -----*****/
    message {
        enabled:                     true;
        margin:                      0px;
        padding:                     0px;
        border:                      0px solid;
        border-radius:               0px 0px 0px 0px;
        border-color:                var(border-colour);
        background-color:            transparent;
        text-color:                  var(foreground-colour);
    }
    textbox {
        padding:                     12px;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                var(border-colour);
        background-color:            var(alternate-background);
        text-color:                  var(foreground-colour);
        vertical-align:              0.5;
        horizontal-align:            0.0;
        highlight:                   none;
        placeholder-color:           var(foreground-colour);
        blink:                       true;
        markup:                      true;
    }
    error-message {
        padding:                     10px;
        border:                      2px solid;
        border-radius:               0px;
        border-color:                var(border-colour);
        background-color:            var(background-colour);
        text-color:                  var(foreground-colour);
    }
  '';
in
{
  stylix.targets.rofi.enable = false;

  xdg.dataFile."rofi/themes/koda.rasi".text = theme;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "koda";
    extraConfig = {
      terminal = "ghostty";
    };
  };
}
