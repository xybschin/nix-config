{ config, ... }:
let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    settings."*" = {
      identityAgent = onePassPath;
    };
  };
}
