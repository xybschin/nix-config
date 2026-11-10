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
    mutableSettings = true;
    settings = {
      autoupdate = false;
    };
    cli = {
      theme = {
        name = "system";
        mode = "system";
      };
    };
  };

  stylix.targets.opencode.enable = false;

  home.shellAliases.oc = "opencode";
}
