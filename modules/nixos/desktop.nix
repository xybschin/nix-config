{ ... }:

{
  programs.dconf.enable = true;
  programs.thunderbird.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
}
