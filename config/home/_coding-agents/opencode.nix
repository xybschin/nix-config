{
  config,
  lib,
  pkgs,
  ...
}:
let
  overlay = import ./local-overlay.nix { inherit lib pkgs; };
in
lib.mkIf (lib.elem "opencode" config.my.coding-agents.agents) {
  programs.opencode = {
    enable = true;
    # OPENCODE_CONFIG is merged on top of the generated global config.
    package = overlay.wrap {
      package = pkgs.opencode;
      bin = "opencode";
      prelude = ''
        if [ -f "${overlay.dir}/opencode/opencode.json" ]; then
          export OPENCODE_CONFIG="${overlay.dir}/opencode/opencode.json"
        fi
      '';
    };
    enableMcpIntegration = true;
    settings = {
      autoupdate = false;
      lsp.nil = {
        command = [ "nil" ];
        extensions = [ ".nix" ];
        settings.nil.formatting.command = [ "nixfmt" ];
      };
    };
    tui = {
      theme = lib.mkForce "system";
    };
  };

  home.shellAliases.oc = "opencode";
}
