{ pkgs, apple-fonts, ... }:
let
  segoe-ui = pkgs.stdenvNoCC.mkDerivation {
    name = "segoe-ui";
    src = pkgs.fetchFromGitHub {
      owner = "mrbvrz";
      repo = "segoe-ui-linux";
      rev = "master";
      sha256 = "sha256-0KXfNu/J1/OUnj0jeQDnYgTdeAIHcV+M+vCPie6AZcU=";
    };
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp -r $src/font/* $out/share/fonts/truetype/
    '';
  };
in
{
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Segoe UI"
          "SF Pro"
          "Inter"
          "Noto Sans"
        ];
        monospace = [ "SF Mono" ];
      };
    };
  };
  home.packages = with pkgs; [
    segoe-ui
    fontpreview
    nerd-fonts.jetbrains-mono
    nerd-fonts.terminess-ttf
    maple-mono.truetype
    corefonts
    vista-fonts
    inter
    noto-fonts
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
    apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
  ];
}
