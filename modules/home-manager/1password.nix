{
  config,
  pkgs,
  isWsl,
  ...
}:
let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  config =
    if isWsl then
      let
        startScript = pkgs.writeShellScript "1password-ssh-bridge" ''
          mkdir -p ~/.1password
          SSH_AGENT_WORKING=$(ssh-add -l >/dev/null 2>&1; echo $?)
          if [[ $SSH_AGENT_WORKING != "0" ]]; then
            kill $(ps -auxww | grep "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" | awk '{print $2}') >/dev/null 2>&1
          fi

          ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
          if [[ $ALREADY_RUNNING != "0" ]]; then
            if [[ -S ${onePassPath} ]]; then
              rm ${onePassPath} >/dev/null 2>&1
            fi
            (setsid ${pkgs.socat}/bin/socat UNIX-LISTEN:${onePassPath},fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
          fi;
        '';
      in
      {
        home = {
          packages = with pkgs; [ socat ];
          sessionVariables = {
            SSH_AUTH_SOCK = onePassPath;
          };
        };

        programs.zsh.initContent = ''
          ${startScript}
        '';
      }
    else
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
      };
}
