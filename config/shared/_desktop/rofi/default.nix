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
        bg:          ${rgba c.base00 "55"};
        bg-alt:      ${rgba c.base01 "88"};
        fg:          ${rgba c.base08 "FF"};
        fg-dim:      ${rgba c.base04 "FF"};
        fg-selected: ${rgba c.base05 "AA"};
        highlight:   ${rgba c.base05 "11"};
        border:      ${rgba c.base01 "88"};
        urgent:      ${rgba c.base0F "FF"};
        active:      ${rgba c.base0A "FF"};
        fg-bright:   ${rgba c.base05 "FF"};
        fg-muted:    ${rgba c.base03 "FF"};
        bg-surface:  ${rgba c.base02 "88"};
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
