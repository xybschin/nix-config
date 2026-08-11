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
      ./_desktop/zen-browser.nix
      ./_desktop/rofi
      ./_desktop/wayland-env.nix
      ./_desktop/hyprpaper
    ];

    home.packages = with pkgs; [
      nautilus
      feh
    ];

    services.udiskie.enable = true;

    dconf.settings = {
      "org/gnome/desktop/media-handling" = {
        automount = true;
        automount-open = false;
      };
    };
  };
}
