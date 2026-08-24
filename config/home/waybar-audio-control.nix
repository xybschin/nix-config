{ ... }:
{
  config.my.features.home.waybar-audio-control =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    let
      c = config.lib.stylix.colors.withHashtag;
    in
    {
      imports = [ inputs.waybar-audio-control.homeManagerModules.default ];

      programs.waybar-audio-control = {
        enable = true;
        package = inputs.waybar-audio-control.packages.${pkgs.stdenv.hostPlatform.system}.default;

        colors = {
          background = c.base00;
          foreground = c.base04;
          accent = c.base0A;
        };

        position = {
          anchor = "bottom-right";
          marginBottom = 1;
          marginTop = 0;
          marginRight = 1;
          marginLeft = 0;
        };
      };
    };
}
