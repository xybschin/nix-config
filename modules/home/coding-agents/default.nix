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

      $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"

      if [ -d "$SKILLS_DIR/.git" ]; then
        $DRY_RUN_CMD $GIT -C "$SKILLS_DIR" pull --ff-only --quiet
      else
        $DRY_RUN_CMD $GIT clone --depth=1 --quiet "${skillsRepo}" "$SKILLS_DIR"
      fi

      for dest in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
        $DRY_RUN_CMD mkdir -p "$dest"
        for skillDir in "$SKILLS_DIR"/*/; do
          skill="$(basename "$skillDir")"
          if [ -L "$dest/$skill" ] || [ -e "$dest/$skill" ]; then
            $DRY_RUN_CMD rm -rf "$dest/$skill"
          fi
          $DRY_RUN_CMD ln -s "''${skillDir%/}" "$dest/$skill"
        done
      done
    '';
  };
}
