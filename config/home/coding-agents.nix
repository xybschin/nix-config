{ ... }:
{
  config.my.features.home.coding-agents = {
    inputs,
    lib,
    pkgs,
    ...
  }:
  let
    skillsRepo = "https://github.com/xybschin/skills.git";
    skillsLocalPath = "$HOME/.local/share/agent-skills";
    hmLib = inputs.home-manager.lib.hm;
  in
  {
    imports = [
      ./_coding-agents/claude-code.nix
      ./_coding-agents/copilot-cli.nix
      ./_coding-agents/opencode.nix
    ];

    programs.mcp = {
      enable = true;
      servers = {
        git.command = lib.getExe pkgs.mcp-server-git;
        nixos.command = lib.getExe pkgs.mcp-nixos;
        firecrawl = {
          command = "${pkgs.nodejs}/bin/npx";
          args = [ "-y" "firecrawl-mcp" ];
          env.FIRECRAWL_API_KEY = "{env:FIRECRAWL_API_KEY}";
        };
        context7 = {
          url = "https://mcp.context7.com/mcp";
          headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };
      };
    };

    home.activation.fetchSkills = hmLib.dag.entryAfter [ "writeBoundary" ] ''
      GIT="${pkgs.git}/bin/git"
      SKILLS_DIR="${skillsLocalPath}"

      $DRY_RUN_CMD rm -rf "$SKILLS_DIR"
      $DRY_RUN_CMD $GIT clone --depth=1 --quiet "${skillsRepo}" "$SKILLS_DIR"

      for dest in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
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
      done

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
    '';
  };
}
