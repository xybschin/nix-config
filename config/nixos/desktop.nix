{ ... }:
{
  config.my.features.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        geary
        kdePackages.plasma-workspace
      ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command =
              let
                uwsm-session = pkgs.runCommand "tuigreet-sessions" { } ''
                  mkdir -p $out
                  ln -s ${pkgs.hyprland}/share/wayland-sessions/hyprland-uwsm.desktop $out/
                '';
              in
              "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${uwsm-session}";
            user = "greeter";
          };
        };
      };

      boot.consoleLogLevel = 0;
    };
}
