{
  config,
  ...
}:
let
  stylix = config.my.features.home."shared.stylix";
in
{
  config.my.features.home."shared.desktop" =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      c = config.lib.stylix.colors;
      rgba = base: a: "rgba(${c."${base}-rgb-r"}, ${c."${base}-rgb-g"}, ${c."${base}-rgb-b"}, ${a})";
    in
    {
      imports = [
        stylix
        ./_desktop/waybar
        ./_desktop/font.nix
        ./_desktop/brave-browser.nix
        ./_desktop/rofi
        ./_desktop/wayland-env.nix
        ./_desktop/hyprpaper
      ];

      stylix.targets.swaync.enable = false;

      home.packages = with pkgs; [
        nautilus
        feh
        zathura
      ];

      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "top";
          layer-shell = true;
          cssPriority = "application";
          notification-2fa-action = true;
          notification-inline-replies = false;
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          widgets = [ "notifications" ];
        };

        style = lib.mkAfter ''
          @define-color bg ${rgba "base00" "0.67"};
          @define-color surface ${rgba "base01" "0.53"};
          @define-color border ${rgba "base01" "0.53"};
          @define-color border-hi ${rgba "base02" "0.53"};
          @define-color border-solid #${c.base02};
          @define-color hover ${rgba "base07" "0.07"};
          @define-color text #${c.base08};
          @define-color bright #${c.base07};
          @define-color muted #${c.base04};
          @define-color accent #${c.base06};
          @define-color critical #${c.base0F};
          @define-color base #${c.base00};
          @define-color slider #${c.base01};
          @define-color bg-solid #${c.base00};
          @define-color surface-solid #${c.base01};

          * {
            all: unset;
            font-family: "${config.stylix.fonts.monospace.name}";
            transition: 0.3s;
            font-size: 0.9rem;
          }

          /* ---------- Floating notifications ---------- */

          .floating-notifications.background .notification-row { padding: 0.25rem 1rem; }

          .floating-notifications.background .notification-row .notification-background {
            border-radius: 3px;
            background-color: @bg;
            color: @text;
            border: none;
          }

          .floating-notifications.background .notification-row .notification-background .notification {
            padding: 0.5rem;
            border-radius: 3px;
            border: 1px solid @border-hi;
          }

          .floating-notifications.background .notification-row .notification-background .notification.critical {
            border: 1px solid @critical;
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
            margin: 0.5rem;
            color: @bright;
            font-weight: bold;
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
            margin: 0.5rem;
            color: @muted;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3rem;
          }

          .notification-action {
            border-radius: 3px;
            color: @muted;
            background-color: @base;
            border: 1px solid @hover;
            padding: 0 10px;
            margin: 0.25rem 2px 0 0;
          }
          .notification-action:hover { background-color: @hover; color: @bright; }
          .notification-action:active { background-color: @hover; color: @accent; }

          .floating-notifications.background .notification-row .notification-background .close-button {
            margin: 0.5rem;
            padding: 0.25rem;
            border-radius: 3px;
            color: @base;
            background-color: @critical;
          }

          .floating-notifications.background .notification-row .notification-background .close-button:hover {
            color: @bright;
          }

          .floating-notifications.background .notification-row .notification-background .close-button:active {
            background-color: @accent;
            color: @base;
          }

          /* ---------- Control center ---------- */

          .control-center {
            border-radius: 3px;
            margin: 1rem;
            background-color: @bg;
            color: @text;
            padding: 1rem;
            border: 1px solid @border;
          }

          .control-center .widget-title {
            color: @accent;
            font-weight: bold;
          }

          .control-center .widget-title button {
            border-radius: 3px;
            color: @text;
            background-color: @surface;
            border: 1px solid @border-hi;
            padding: 0.5rem;
          }

          .control-center .widget-title button:hover {
            background-color: @hover;
            color: @accent;
          }

          .control-center .widget-title button:active { background-color: @border-solid; }

          .control-center .notification-row .notification-background {
            border-radius: 3px;
            margin: 0.5rem 0;
            background-color: @surface-solid;
            color: @text;
            border: none;
          }

          .control-center .notification-row .notification-background .notification {
            padding: 0.5rem;
            border-radius: 3px;
            border: 1px solid @border-hi;
          }

          .control-center .notification-row .notification-background .notification.critical {
            border: 1px solid @critical;
          }

          .control-center .notification-row .notification-background .notification .notification-content {
            color: @text;
          }

          .control-center .notification-row .notification-background .notification .notification-content .summary {
            margin: 0.5rem;
            color: @bright;
            font-weight: bold;
          }

          .control-center .notification-row .notification-background .notification .notification-content .body {
            margin: 0.5rem;
            color: @muted;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3rem;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
            border-radius: 3px;
            color: @text;
            background-color: @bg-solid;
            border: 1px solid @border-hi;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
            background-color: @hover;
            color: @accent;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
            background-color: @border-solid;
          }

          .control-center .notification-row .notification-background .close-button {
            margin: 0.5rem;
            padding: 0.25rem;
            border-radius: 3px;
            color: @base;
            background-color: @critical;
          }

          .control-center .notification-row .notification-background .close-button:hover {
            color: @bright;
          }

          .control-center .notification-row .notification-background .close-button:active {
            background-color: @accent;
            color: @base;
          }

          /* ---------- Progress ---------- */

          progressbar,
          progress,
          trough {
            border-radius: 3px;
          }

          .notification.critical progress { background-color: @critical; }

          .notification.low progress,
          .notification.normal progress {
            background-color: @accent;
          }

          trough { background-color: @surface; }

          .control-center trough { background-color: @border-solid; }

          /* ---------- DND ---------- */

          .control-center-dnd {
            margin: 1rem 0;
            border-radius: 3px;
          }

          .control-center-dnd slider {
            background: @slider;
            border-radius: 3px;
          }

          .widget-dnd { color: @muted; }

          .widget-dnd > switch {
            border-radius: 3px;
            background: @surface;
            border: 1px solid @border-hi;
          }

          .widget-dnd > switch:checked slider { background: @accent; }

          .widget-dnd > switch slider {
            background: @muted;
            border-radius: 3px;
            margin: 0.25rem;
          }

          .notification .notification-content .image,
          .notification .notification-content .app-icon {
            -gtk-icon-size: 1.5rem;
            margin: 0.5rem 0 4rem 0.5rem;
            min-width: 1.5rem;
            min-height: 1.5rem;
          }
        '';
      };

      services.udiskie.enable = true;

      dconf.settings = {
        "org/gnome/desktop/media-handling" = {
          automount = true;
          automount-open = false;
        };
      };
    };
}
