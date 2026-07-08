{
  config,
  pkgs,
  lib,
  isWsl ? false,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isNative = !isWsl && !isDarwin;

  onePassPath =
    if isWsl then
      "${config.home.homeDirectory}/.ssh/ssh-agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";

  # Sourced in every interactive shell. Checks if the bridge is healthy via
  # ssh-add, restarts socat if broken. Uses setsid so it outlives the shell.
  # Only used on WSL.
  wslBridgeScript = pkgs.writeShellScript "1password-ssh-bridge" ''
    # Code extracted from https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/
    # (IMPORTANT) Create the folder on your root for the `agent.sock` (As mentioned by @rfay and @Lochnair in the comments)
    # mkdir -p ~/.1password

    # Configure ssh forwarding
    export SSH_AUTH_SOCK=$HOME/.ssh/ssh-agent.sock

    # need `ps -ww` to get non-truncated command for matching
    # use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!

    # Contribution below made by @SJ50 (in the comments)
    SSH_AGENT_WORKING=$(ssh-add -l >/dev/null 2>&1; echo $?)
    if [[ $SSH_AGENT_WORKING != "0" ]]; then
        # echo "ssh agent not working, killing npiperelay.exe"
        kill $(ps -auxww | grep "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" | awk '{print $2}') >/dev/null 2>&1
    fi

    ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
    if [[ $ALREADY_RUNNING != "0" ]]; then

        if [[ -S $SSH_AUTH_SOCK ]]; then
            # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
            # echo "removing previous socket..."
            rm $SSH_AUTH_SOCK >/dev/null 2>&1
        fi
        # echo "Starting SSH-Agent relay..."
        # setsid to force new session to keep running
        # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
        (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
  '';
in
{
  home.packages = lib.optionals isWsl [ pkgs.socat ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = isDarwin;
    settings."*" = {
      identityAgent = onePassPath;
    };
  };

  home.sessionVariables = lib.optionalAttrs (!isDarwin) {
    SSH_AUTH_SOCK = onePassPath;
  };

  systemd.user.services."1password" = lib.optionalAttrs isNative {
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

  programs.zsh.initContent = lib.optionalString isWsl ''
    source ${wslBridgeScript}
  '';
}
