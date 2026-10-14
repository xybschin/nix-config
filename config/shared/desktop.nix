{
  config,
  ...
}:
let
  stylix = config.my.features.home."shared.stylix";
in
{
  config.my.features.home."shared.desktop" = { pkgs, ... }: {
    imports = [
      stylix
      ./_desktop/waybar
      ./_desktop/font.nix
      ./_desktop/brave-browser.nix
      ./_desktop/rofi
      ./_desktop/wayland-env.nix
      ./_desktop/hyprpaper
    ];

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
        control-center-margin-top = 0;
        control-center-margin-bottom = 0;
        control-center-margin-right = 0;
        control-center-margin-left = 0;
        notification-2fa-action = true;
        notification-inline-replies = false;
        notification-icon-size = 64;
        notification-body-image-height = 100;
        notification-body-image-width = 200;
      };
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
