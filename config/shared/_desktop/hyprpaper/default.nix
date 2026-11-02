{ config, configRoot, lib, ... }:
let
  wallpapersDir = "${configRoot}/config/shared/_desktop/hyprpaper/wallpapers/single";
in
{
  services.hyprpaper.enable = true;
  stylix.targets.hyprpaper.enable = false;
  home.file.wallpapers.source = config.lib.file.mkOutOfStoreSymlink "${wallpapersDir}";

  # hyprpaper.conf is owned by the quickshell wallpaper bar at runtime (it
  # rewrites wallpaper blocks on every pick), so home-manager can't generate
  # it — a store symlink would break the bar's writes. Seed `splash = false`
  # (disables the text rendered at the bottom of the screen) into the file
  # here instead; the bar's rewrites preserve non-wallpaper lines.
  home.activation.hyprpaperNoSplash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="${config.xdg.configHome}/hypr/hyprpaper.conf"
    mkdir -p "$(dirname "$conf")"
    touch "$conf"
    if ! grep -qE '^[[:space:]]*splash[[:space:]]*=' "$conf"; then
      { echo 'splash = false'; cat "$conf"; } > "$conf.tmp" && mv "$conf.tmp" "$conf"
    fi
  '';
}
