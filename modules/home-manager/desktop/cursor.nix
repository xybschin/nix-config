{ pkgs, ... }:
{
  home.pointerCursor = {
    name = "macOS Cursors";
    package = pkgs.apple-cursor;
    size = 22;
    gtk.enable = true;
    x11.enable = true;
  };
}
