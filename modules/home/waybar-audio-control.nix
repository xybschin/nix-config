{ inputs, pkgs, ... }:
{
  imports = [ inputs.waybar-audio-control.homeManagerModules.default ];
  programs.waybar-audio-control = {
    enable = true;
    package = inputs.waybar-audio-control.packages.${pkgs.stdenv.hostPlatform.system}.default;

    colors = {
      background = "#101010";
      foreground = "#b0b0b0";
      accent = "#d9ba73";
    };

    position = {
      anchor = "bottom-right";
      marginBottom = 1;
      marginTop = 0;
      marginRight = 1;
      marginLeft = 0;
    };
  };
}
