{
  pkgs,
  inputs,
  ...
}:
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
  home.packages = with pkgs; [
    segoe-ui
    fontpreview
    nerd-fonts.terminess-ttf
    maple-mono.truetype
    corefonts
    vista-fonts
    noto-fonts
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
  ];
}
