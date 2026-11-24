{ ... }:
{
  # System half of Hyprland: install the session and greet the user into it.
  # The user half (Lua config, hyprlock, hyprpaper, quickshell) lives in the
  # `shared.desktop.wm.hyprland` home feature.
  config.my.features.nixos.hyprland =
    { pkgs, ... }:
    {
      # hyprlock authenticates through its own PAM service; without it, it
      # falls back to /etc/pam.d/su.
      security.pam.services.hyprlock = { };

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      # xdg-desktop-portal-hyprland keeps one PipeWire core connection from
      # startup and does not reconnect if PipeWire restarts. Tie the portal
      # services to PipeWire's lifecycle so a crash or rebuild restarts them
      # too; otherwise Discord screen sharing times out until the portal is
      # restarted by hand.
      systemd.user.services."xdg-desktop-portal" = {
        unitConfig = {
          PartOf = [
            "pipewire.service"
            "wireplumber.service"
          ];
          Requires = [
            "pipewire.service"
            "wireplumber.service"
          ];
          After = [
            "pipewire.service"
            "wireplumber.service"
          ];
        };
      };

      systemd.user.services."xdg-desktop-portal-hyprland" = {
        unitConfig = {
          PartOf = [
            "pipewire.service"
            "wireplumber.service"
          ];
          Requires = [
            "pipewire.service"
            "wireplumber.service"
          ];
          After = [
            "pipewire.service"
            "wireplumber.service"
          ];
        };
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
