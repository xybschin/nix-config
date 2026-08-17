{ ... }:
{
  config.my.features.nixos.desktop =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.hyprland.nixosModules.default
      ];

      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        geary
        kdePackages.breeze-icons
        kdePackages.plasma-workspace
      ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = let
              hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
              uwsm-session = pkgs.runCommand "tuigreet-sessions" { } ''
                mkdir -p $out
                ln -s ${hyprland}/share/wayland-sessions/hyprland-uwsm.desktop $out/
              '';
            in "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${uwsm-session}";
            user = "greeter";
          };
        };
      };

      boot.consoleLogLevel = 0;
    };
}
