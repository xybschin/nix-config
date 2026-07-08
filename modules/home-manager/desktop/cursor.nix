{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "macOS-hypr";
    HYPRCURSOR_SIZE = "28";
    XCURSOR_THEME = "macOS-hypr";
    XCURSOR_SIZE = "28";
  };
}
