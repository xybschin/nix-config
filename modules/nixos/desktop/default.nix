{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.desktop.enable = lib.mkEnableOption "Desktop (Hyprland)";

  config = lib.mkIf config.my.desktop.enable (
    let
      hyprlandPkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    in
    {
      programs.dconf.enable = true;
      programs.thunderbird.enable = true;
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
        package = hyprlandPkg;
        # portal package must stay in sync with the compositor package
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${hyprlandPkg}/share/wayland-sessions";
            user = "greeter";
          };
        };
      };

      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    }
  );
}
