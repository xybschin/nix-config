{ ... }:
let
  sshSockPath = "~/.1password/agent.sock";
in
{
  home.sessionVariables = {
    SSH_AUTH_SOCK = sshSockPath;
  };
}
