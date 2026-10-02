{
  config,
  pkgs,
  ...
}:
let
  c = config.lib.stylix.colors;
  rgba = hex: alpha: "#${hex}${alpha}";
  colors = ''
    * {
        background:      ${rgba c.base00 "FF"};
        background-alt:  ${rgba c.base01 "FF"};
        foreground:      ${rgba c.base08 "FF"};
        foreground-dim:  ${rgba c.base04 "FF"};
        selected:        ${rgba c.base05 "FF"};
        urgent:          ${rgba c.base0F "FF"};
        active:          ${rgba c.base0A "FF"};
    }
  '';
in

{
  imports = [
    ./koda-launcher.nix
    ./koda-power.nix
  ];

  stylix.targets.rofi.enable = false;
  xdg.dataFile."rofi/themes/koda-colors.rasi".text = colors;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "koda-launcher";
    settings = {
      terminal = "ghostty";
    };
  };
}
