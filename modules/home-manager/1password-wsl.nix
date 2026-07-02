{ config, pkgs, ... }:
let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";

  # Sourced in every interactive shell. Starts the socat bridge in the background
  # using setsid so it outlives the shell. Running from the shell (not systemd)
  # gives it access to the full WSL PATH, including Windows interop paths where
  # npiperelay.exe lives.
  #
  # ssh-add exit codes: 0 = ok+identities, 1 = ok+no identities (vault locked), 2 = no socket
  # We only restart on exit code 2 (broken/missing socket); exit 1 is healthy.
  startScript = pkgs.writeShellScript "1password-ssh-bridge" ''
    mkdir -p ~/.1password

    ALREADY_RUNNING=$(ps -auxww | grep -c "[s]ocat.*${onePassPath}")
    if [[ $ALREADY_RUNNING -gt 0 ]]; then
      exit 0
    fi

    # Remove stale socket if present
    rm -f ${onePassPath}

    (setsid ${pkgs.socat}/bin/socat \
      UNIX-LISTEN:${onePassPath},fork \
      EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork \
      </dev/null >/dev/null 2>&1 &)
  '';
in
{
  home.packages = with pkgs; [ socat ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      identityAgent = onePassPath;
    };
  };

  home.sessionVariables.SSH_AUTH_SOCK = onePassPath;

  programs.zsh.initContent = ''
    ${startScript}
  '';
}
