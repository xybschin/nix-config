{ pkgs, ... }:
let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.runtimeShell} -c "
            ${pkgs.wlr-randr}/bin/wlr-randr \
              --output DP-1 --mode 2560x1440 --pos 0,0 \
              --output HDMI-A-1 --mode 2560x1440 --pos 2560,0;
            
            "${tuigreet} --time --asterisks --remember --remember-session"
          "
        '';
        user = "greeter";
      };
    };
  };
}
