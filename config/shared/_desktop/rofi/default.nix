{
  pkgs,
  ...
}:

{
  imports = [
    ./launcher.nix
    ./powermenu.nix
  ];

  stylix.targets.rofi.enable = false;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    # Default theme, overridden per invocation for the other menus
    theme = "koda";
    extraConfig = {
      terminal = "ghostty";
    };
  };
}
