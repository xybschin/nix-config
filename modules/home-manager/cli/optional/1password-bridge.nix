{
  pkgs,
  lib,
  ...
}:
let
  sshSockPath = "~/.1password/agent.sock";
  startScript = pkgs.writeShellScript "1password-ssh-bridge" ''
    # https://gist.github.com/WillianTomaz/a972f544cc201d3fbc8cd1f6aeccef51
    mkdir -p ~/.1password
    SSH_AGENT_WORKING=$(ssh-add -l >/dev/null 2>&1; echo $?)
    if [[ $SSH_AGENT_WORKING != "0" ]]; then
      echo "ssh agent not working, killing npiperelay.exe"
      kill $(ps -auxww | grep "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" | awk '{print $2}') >/dev/null 2>&1
    fi

    ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
    if [[ $ALREADY_RUNNING != "0" ]]; then
      # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
      if [[ -S $SSH_AUTH_SOCK ]]; then
        # echo "removing previous socket..."
        rm $SSH_AUTH_SOCK >/dev/null 2>&1
      fi
      echo "Starting SSH-Agent relay..."
      (setsid ${pkgs.socat}/bin/socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi;
  '';
in
{
  home.packages = with pkgs; [ socat ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = sshSockPath;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityAgent = sshSockPath;
      };
    };
  };

  systemd.user.services.ssh-agent.Service.ExecStart = lib.mkForce "";
  systemd.user.services.ssh-agent.Install.WantedBy = lib.mkForce [ ];

  programs.zsh.initContent = ''
    ${startScript}
  '';
}
