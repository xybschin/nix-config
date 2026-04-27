{ pkgs, apple-fonts, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Segoe UI" ];
        monospace = [ "SF Mono" ];
      };
    };
  };
  home.packages = with pkgs; [
    fontpreview
    nerd-fonts.jetbrains-mono
    nerd-fonts.terminess-ttf
    maple-mono.truetype
    corefonts
    vista-fonts
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
  ];
}
