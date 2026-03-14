{ ... }:
let
  onePassPath = "~/.1password/agent.sock";
in
{

  programs.ssh = {
    enableDefaultConfig = false;
    enable = true;

    matchBlocks."*" = {
      identityAgent = onePassPath;
    };
  };
  home.sessionVariables = {
    SSH_AUTH_SOCK = onePassPath;
  };
}
