{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  skillsRepo = "https://github.com/xybschin/skills.git";
  skillsLocalPath = "$HOME/.local/share/agent-skills";
  hmLib = inputs.home-manager.lib.hm;
in
{
  home.packages = [
    pkgs.claude-code
    pkgs.github-copilot-cli
  ];

  programs.opencode = {
    enable = true;

    settings = {
      lsp = {
        nil = {
          command = [ "nil" ];
          extensions = [ ".nix" ];
          settings = {
            nil = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
        };
      };
    };
  };

  home.shellAliases = {
    cc = "claude";
    cop = "copilot";
    oc = "opencode";
  };

  home.activation = {
    fetchSkills = hmLib.dag.entryAfter [ "writeBoundary" ] ''
      GIT="${pkgs.git}/bin/git"
      SKILLS_DIR="${skillsLocalPath}"

      # Treat the dir as a read-only cache: wipe and reclone on every run so
      # stale untracked files can never block the clone.
      $DRY_RUN_CMD rm -rf "$SKILLS_DIR"
      $DRY_RUN_CMD $GIT clone --depth=1 --quiet "${skillsRepo}" "$SKILLS_DIR"

      # Skills are grouped as skills/<group>/<skill>/; flatten into the three
      # discovery locations opencode and claude-code read from. Removing every
      # managed symlink first prunes skills that have since been removed upstream.
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

      # Link opencode command files (commands/<name>.md) into the commands dir.
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
