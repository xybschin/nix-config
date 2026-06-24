{
  lib,
  pkgs,
  ...
}:

let
  skillsRepo = "https://github.com/xybschin/agent-skills.git";
  skillsLocalPath = "$HOME/.local/share/agent-skills";
in
{
  home.packages = [
    pkgs.claude-code
    pkgs.github-copilot-cli
    pkgs.opencode
  ];

  home.shellAliases = {
    cc = "claude";
    cop = "copilot";
    oc = "opencode";
  };

  home.activation = {
    fetchSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      GIT="${pkgs.git}/bin/git"
      SKILLS_DIR="${skillsLocalPath}"

      $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"

      if [ -d "$SKILLS_DIR/.git" ]; then
        $DRY_RUN_CMD $GIT -C "$SKILLS_DIR" pull --ff-only --quiet
      else
        $DRY_RUN_CMD $GIT clone --depth=1 --quiet "${skillsRepo}" "$SKILLS_DIR"
      fi

      # Symlink each skill dir into all tool locations
      for skillDir in "$SKILLS_DIR"/*/; do
        skill="$(basename "$skillDir")"
        for dest in "$HOME/.copilot/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
          $DRY_RUN_CMD mkdir -p "$dest"
          if [ -L "$dest/$skill" ] || [ -e "$dest/$skill" ]; then
            $DRY_RUN_CMD rm -rf "$dest/$skill"
          fi
          $DRY_RUN_CMD ln -s "$skillDir" "$dest/$skill"
        done
      done
    '';
  };
}
