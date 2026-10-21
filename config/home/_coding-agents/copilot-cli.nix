{
  config,
  lib,
  pkgs,
  ...
}:

let
  overlay = import ./local-overlay.nix { inherit lib pkgs; };
  jsonFormat = pkgs.formats.json { };
  initialConfig = jsonFormat.generate "copilot-config.json" {
    autoUpdate = false;
    includeCoAuthoredBy = false;
  };
  mcpConfig = jsonFormat.generate "copilot-mcp-config.json" {
    mcpServers = {
      git = {
        type = "local";
        command = lib.getExe pkgs.mcp-server-git;
        args = [ ];
        tools = [ "*" ];
      };
      nixos = {
        type = "local";
        command = lib.getExe pkgs.mcp-nixos;
        args = [ ];
        tools = [ "*" ];
      };
    };
  };
in
lib.mkIf (lib.elem "copilot" config.my.coding-agents.agents) {
  home = {
    packages = [
      (overlay.wrap {
        package = pkgs.github-copilot-cli;
        bin = "copilot";
        # Adds servers on top of the read-only ~/.copilot/mcp-config.json;
        # same-named servers in the local file win.
        prelude = ''
          if [ -f "${overlay.dir}/copilot-mcp.json" ]; then
            set -- --additional-mcp-config=@"${overlay.dir}/copilot-mcp.json" "$@"
          fi
        '';
      })
    ];
    shellAliases.cop = "copilot";
    file = {
      ".copilot/mcp-config.json".source = mcpConfig;
    };
  };

  home.activation.generateCopilotConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    copilotDir="$HOME/.copilot"
    configFile="$copilotDir/config.json"
    mkdir -p "$copilotDir"
    if [ -f "$configFile" ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$configFile" ${initialConfig} > "$configFile.tmp" &&
        mv "$configFile.tmp" "$configFile"
    else
      cp --no-preserve=mode ${initialConfig} "$configFile"
      chmod 644 "$configFile"
    fi
  '';
}
