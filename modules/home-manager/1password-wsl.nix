{ config, pkgs, ... }:
let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";

  # Service script: sets up Windows PATH (for npiperelay.exe) then starts socat.
  # Systemd user services don't inherit WSL Windows interop PATH, so we resolve it
  # via cmd.exe the same way the zsh _fix_wsl_path helper does.
  serviceScript = pkgs.writeShellScript "1password-ssh-bridge-service" ''
    # Bring Windows PATH entries into scope so npiperelay.exe is findable.
    win_path=$(/mnt/c/Windows/System32/cmd.exe /c "echo %PATH%" 2>/dev/null | tr -d '\r')
    if [[ -n "$win_path" ]]; then
      unix_paths=()
      while IFS=';' read -ra parts; do
        for part in "''${parts[@]}"; do
          drive=$(echo "$part" | cut -c1 | tr '[:upper:]' '[:lower:]')
          rest=$(echo "$part" | cut -c3- | sed 's|\\|/|g')
          unix_paths+=("/mnt/$drive$rest")
        done
      done <<< "$win_path"
      export PATH="$PATH:$(IFS=:; echo "''${unix_paths[*]}")"
    fi

    mkdir -p ${config.home.homeDirectory}/.1password
    # Remove stale socket if present
    rm -f ${onePassPath}
    exec ${pkgs.socat}/bin/socat \
      UNIX-LISTEN:${onePassPath},fork \
      EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
  '';

  # Shell script run in every interactive zsh session as a lightweight check/fallback.
  # Uses exit code 2 (not 1) to detect a broken socket — exit 1 means agent is running
  # but vault is locked, which is healthy and should not trigger a restart.
  startScript = pkgs.writeShellScript "1password-ssh-bridge" ''
    mkdir -p ~/.1password

    # ssh-add exit codes: 0=ok+identities, 1=ok+no identities (vault locked), 2=no socket
    ssh-add -l >/dev/null 2>&1
    SSH_AGENT_STATUS=$?

    if [[ $SSH_AGENT_STATUS == "2" ]]; then
      # Socket is broken — kill stale npiperelay and let systemd restart the service.
      kill $(ps -auxww | grep "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" | awk '{print $2}') >/dev/null 2>&1
      systemctl --user restart 1password-ssh-bridge.service >/dev/null 2>&1 || true
    fi
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

  # Systemd user service keeps the socat bridge alive across crashes and reboots.
  # Without this, SSH tools that run without an interactive shell (VS Code Remote,
  # scp, git over SSH) fail with "Error connecting to agent: No such file or directory"
  # because SSH_AUTH_SOCK is set but the socket file doesn't exist.
  systemd.user.services."1password-ssh-bridge" = {
    Unit = {
      Description = "1Password SSH agent bridge (WSL → Windows named pipe via socat)";
      After = "default.target";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${serviceScript}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # In interactive shells, check if the bridge is working and restart it if broken.
  programs.zsh.initContent = ''
    ${startScript}
  '';
}
