{ ... }:
{
  config.my.features.home.coding-agents =
    {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      skillsRepo = "https://github.com/xybschin/skills.git";
      skillsLocalPath = "$HOME/.local/share/agent-skills";
      mattSkills = inputs.mattpocock-skills;
      hmLib = inputs.home-manager.lib.hm;

      allAgents = [
        "claude"
        "copilot"
        "opencode"
      ];

      # CODING_AGENTS (make's with= arg, or the gitignored .feature-overrides
      # file) wins over the host's my.coding-agents.agents so a machine can
      # drop agents for one rebuild — e.g. a customer project — without
      # editing the config. `none` selects an agent-less machine.
      parseAgents =
        raw:
        let
          tokens = lib.filter (t: t != "") (lib.splitString " " raw);
          unknown = lib.filter (t: !lib.elem t allAgents) tokens;
        in
        if raw == "none" then
          [ ]
        else if unknown != [ ] then
          throw "CODING_AGENTS: unknown agent(s) ${lib.concatStringsSep ", " unknown} (expected: ${lib.concatStringsSep ", " allAgents}, or none)"
        else
          tokens;
      envAgents =
        let
          raw = builtins.getEnv "CODING_AGENTS";
        in
        if raw == "" then null else parseAgents raw;

      agents = config.my.coding-agents.agents;
      wants = agent: lib.elem agent agents;

      # Skill dirs per allowed agent; disallowed agents' dirs are not touched.
      skillDirs = [
        "$HOME/.agents/skills"
      ]
      ++ lib.optional (wants "claude") "$HOME/.claude/skills"
      ++ lib.optional (wants "opencode") "$HOME/.config/opencode/skills";
    in
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        ./_coding-agents/options.nix
        ./_coding-agents/claude-code.nix
        ./_coding-agents/copilot-cli.nix
        ./_coding-agents/opencode.nix
      ];

      my.coding-agents.agents = lib.mkIf (envAgents != null) (lib.mkForce envAgents);

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        secrets = lib.mkIf (agents != [ ]) {
          context7_api_key = { };
        };
      };

      programs.mcp = lib.mkIf (agents != [ ]) {
        enable = true;
        servers = {
          git.command = lib.getExe pkgs.mcp-server-git;
          context7 = {
            url = "https://mcp.context7.com/mcp";
            headers.CONTEXT7_API_KEY = "{file:${config.sops.secrets.context7_api_key.path}}";
          };
        };
      };

      home.activation.fetchSkills = hmLib.dag.entryAfter [ "writeBoundary" ] ''
        GIT="${pkgs.git}/bin/git"
        SKILLS_DIR="${skillsLocalPath}"

        $DRY_RUN_CMD rm -rf "$SKILLS_DIR"
        $DRY_RUN_CMD $GIT clone --depth=1 --quiet "${skillsRepo}" "$SKILLS_DIR"

        for dest in ${lib.concatMapStringsSep " " (d: ''"${d}"'') skillDirs}; do
          $DRY_RUN_CMD mkdir -p "$dest"
          for link in "$dest"/*; do
            [ -L "$link" ] || continue
            $DRY_RUN_CMD rm -f "$link"
          done
          for groupDir in "$SKILLS_DIR"/skills/*/; do
            [ -d "$groupDir" ] || continue
            for skillDir in "$groupDir"*/; do
              [ -d "$skillDir" ] || continue
              skill="$(basename "$skillDir")"
              $DRY_RUN_CMD ln -sfn "''${skillDir%/}" "$dest/$skill"
            done
          done
          # Upstream skills named in the repo's list, linked from the pinned flake input.
          LIST="$SKILLS_DIR/upstream-skills.txt"
          if [ -f "$LIST" ]; then
            while read -r skill; do
              case "$skill" in "" | \#*) continue ;; esac
              for skillDir in "${mattSkills}"/skills/*/"$skill"; do
                [ -d "$skillDir" ] || continue
                $DRY_RUN_CMD ln -sfn "$skillDir" "$dest/$skill"
              done
            done < "$LIST"
          fi
        done
        ${lib.optionalString (wants "opencode") ''
          CMD_DEST="$HOME/.config/opencode/commands"
          $DRY_RUN_CMD mkdir -p "$CMD_DEST"
          for link in "$CMD_DEST"/*.md; do
            [ -L "$link" ] || continue
            $DRY_RUN_CMD rm -f "$link"
          done
          for cmdFile in "$SKILLS_DIR"/commands/*.md; do
            [ -f "$cmdFile" ] || continue
            $DRY_RUN_CMD ln -sfn "$cmdFile" "$CMD_DEST/$(basename "$cmdFile")"
          done
        ''}
      '';
    };
}
