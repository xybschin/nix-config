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
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
        # Copilot expands ${VAR}; the wrapper exports the sops secret.
        headers.CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";
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
        secretEnv.CONTEXT7_API_KEY = config.sops.secrets.context7_api_key.path;
        # Customer-specific, untracked Copilot configuration. Copilot supports
        # an additive MCP config and an alternate providers file directly. It
        # has no LSP-config path option, so link its standard location when a
        # local LSP config is present; `/lsp` then writes to the local file.
        # The Nix-managed MCP servers remain available, with local
        # same-named servers taking precedence.
        prelude = ''
          localCopilotDir="${overlay.dir}/copilot"

          if [ -f "$localCopilotDir/mcp-config.json" ]; then
            set -- --additional-mcp-config=@"$localCopilotDir/mcp-config.json" "$@"
          fi

          if [ -f "$localCopilotDir/providers.json" ]; then
            export COPILOT_PROVIDERS_CONFIG="$localCopilotDir/providers.json"
          fi

          if [ -f "$localCopilotDir/lsp-config.json" ]; then
            mkdir -p "$HOME/.copilot"
            ln -sfn "$localCopilotDir/lsp-config.json" "$HOME/.copilot/lsp-config.json"
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
