{ config, pkgs, ... }:
let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  programs.ssh = {
    enableDefaultConfig = false;
    enable = true;
    settings."*" = {
      identityAgent = onePassPath;
    };
  };

  home.sessionVariables.SSH_AUTH_SOCK = onePassPath;

  systemd.user.services."1password" = {
    Unit = {
      Description = "1Password desktop app";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
