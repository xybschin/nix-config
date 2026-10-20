{ ... }:
{
  # System half of Hyprland: install the session and greet the user into it.
  # The user half (Lua config, hyprlock, hyprpaper, quickshell) lives in the
  # `shared.desktop.wm.hyprland` home feature.
  config.my.features.nixos.hyprland =
    { pkgs, ... }:
    {
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
    };
}
