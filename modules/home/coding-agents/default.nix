{
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
    ./claude-code.nix
    ./copilot-cli.nix
    ./opencode.nix
  ];

  programs.mcp = {
    enable = true;
    servers.nixos.command = lib.getExe pkgs.mcp-nixos;
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
}
