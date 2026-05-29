{
  lib,
  pkgs,
  ...
}:

let
  sharedAllowedTools = [
    # VCS
    "git"
    "gh"
    # Nix
    "nix"
    "nix-build"
    "nix-instantiate"
    "nix-locate"
    "nix-prefetch-url"
    "nix-shell"
    "nix-store"
    "nixos-option"
    "nixos-rebuild"
    "nixpkgs-fmt"
    "alejandra"
    "devenv"
    "direnv"
    "home-manager"
    "nom"
    "nvd"
    "statix"
    # .NET
    "dotnet"
    "dotnet-script"
    "nuget"
    "msbuild"
    "csharp"
    "paket"
    # Node / JS
    "node"
    "npm"
    "npx"
    "bun"
    # Python
    "python"
    "python3"
    "pytest"
    "uv"
    "uvx"
    # Linters / formatters
    "gitleaks"
    "pre-commit"
    "ruff"
    "shellcheck"
    "shfmt"
    # Core Unix utilities
    "awk"
    "basename"
    "bat"
    "cat"
    "cloc"
    "command"
    "cp"
    "cut"
    "delta"
    "df"
    "diff"
    "dig"
    "dirname"
    "du"
    "dust"
    "echo"
    "env"
    "eza"
    "fastfetch"
    "fd"
    "file"
    "find"
    "getconf"
    "glow"
    "grep"
    "head"
    "host"
    "hyperfine"
    "jless"
    "jq"
    "journalctl"
    "kill"
    "ldd"
    "lizard"
    "ls"
    "lsblk"
    "lscpu"
    "lsof"
    "lspci"
    "lsusb"
    "mkdir"
    "mv"
    "pgrep"
    "ping"
    "printenv"
    "printf"
    "procs"
    "ps"
    "pwd"
    "readlink"
    "rg"
    "sed"
    "sleep"
    "sort"
    "ss"
    "stat"
    "tail"
    "tee"
    "test"
    "tokei"
    "touch"
    "tr"
    "tree"
    "uname"
    "uniq"
    "unzip"
    "wc"
    "which"
    "who"
    "xargs"
    "xxd"
    "yq"
    "curl"
  ];

  sharedTheme = "dark";
  sharedReasoningEffort = "high";
  copilotTrustedFolders = [ "~" ];

  skillsRepo = "https://github.com/xybschin/agent-skills.git";
  skillsLocalPath = "$HOME/.local/share/agent-skills";

  claudeConfig = builtins.toFile "claude-config.json" (
    builtins.toJSON {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";

      permissions = {
        allow = (map (t: "Bash(${t}:*)") sharedAllowedTools) ++ [
          "Bash(claude:*)"
          "Read(/**)"
          "Write(/**)"
          "Edit(/**)"
          "Glob(**)"
          "Grep"
          "WebFetch"
          "WebSearch"
        ];

        deny = [
          "Read(~/.ssh/**)"
          "Write(~/.ssh/**)"
          "Edit(~/.ssh/**)"
          "Read(~/.gnupg/**)"
          "Write(~/.gnupg/**)"
          "Edit(~/.gnupg/**)"
        ];
      };

      alwaysThinkingEnabled = true;
      effortLevel = sharedReasoningEffort;
      theme = "${sharedTheme}-ansi";
      editorMode = "normal";
      terminalProgressBarEnabled = false;
      autoUpdatesChannel = "stable";
      autoMemoryEnabled = true;
      teammateMode = "tmux";

      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1";
      };
    }
  );

  copilotConfig = builtins.toFile "copilot-config.json" (
    builtins.toJSON {
      model = "claude-sonnet-4-6";
      reasoning_effort = sharedReasoningEffort;
      theme = sharedTheme;
      render_markdown = true;
      banner = false;
      allowedTools = sharedAllowedTools;
      trusted_folders = copilotTrustedFolders;
    }
  );
in
{
  home.packages = [
    pkgs.claude-code
    pkgs.github-copilot-cli
  ];

  home.shellAliases = {
    cc = "claude";
    cop = "copilot";
    oc = "opencode";
  };

  home.file = {
    ".claude/CLAUDE.md".source = ./config/CLAUDE.md;
    ".copilot/instructions.md".source = ./config/CLAUDE.md;
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

      # Symlink each skill dir into all three tool locations
      for skillDir in "$SKILLS_DIR"/*/; do
        skill="$(basename "$skillDir")"
        for dest in "$HOME/.claude/skills" "$HOME/.copilot/skills" "$HOME/.opencode/skills"; do
          $DRY_RUN_CMD mkdir -p "$dest"
          if [ -L "$dest/$skill" ] || [ -e "$dest/$skill" ]; then
            $DRY_RUN_CMD rm -rf "$dest/$skill"
          fi
          $DRY_RUN_CMD ln -s "$skillDir" "$dest/$skill"
        done
      done
    '';

    ai-cli-settings-merge = lib.hm.dag.entryAfter [ "writeBoundary" "fetchSkills" ] ''
      CLAUDE_SETTINGS="$HOME/.claude/settings.json"
      COPILOT_SETTINGS="$HOME/.copilot/settings.json"
      CLAUDE_CONFIG="${claudeConfig}"
      COPILOT_CONFIG="${copilotConfig}"
      JQ="${pkgs.jq}/bin/jq"

      $DRY_RUN_CMD mkdir -p "$HOME/.claude" "$HOME/.copilot"

      if [ ! -f "$CLAUDE_SETTINGS" ]; then
        $DRY_RUN_CMD cp "$CLAUDE_CONFIG" "$CLAUDE_SETTINGS"
      else
        $DRY_RUN_CMD $JQ \
          --slurpfile mine "$CLAUDE_CONFIG" \
          '
            ($mine[0] * .) |
            .permissions.allow = (
              (($mine[0].permissions.allow // []) + (.permissions.allow // [])) | unique
            ) |
            .permissions.deny = (
              (($mine[0].permissions.deny // []) + (.permissions.deny // [])) | unique
            ) |
            .env = ($mine[0].env * (.env // {}))
          ' "$CLAUDE_SETTINGS" > "''${CLAUDE_SETTINGS}.tmp" \
          && mv "''${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
      fi

      if [ ! -f "$COPILOT_SETTINGS" ]; then
        $DRY_RUN_CMD cp "$COPILOT_CONFIG" "$COPILOT_SETTINGS"
      else
        $DRY_RUN_CMD $JQ \
          --slurpfile mine "$COPILOT_CONFIG" \
          '
            ($mine[0] * .) |
            .allowedTools = (
              (($mine[0].allowedTools // []) + (.allowedTools // [])) | unique
            ) |
            .trusted_folders = (
              (($mine[0].trusted_folders // []) + (.trusted_folders // [])) | unique
            )
          ' "$COPILOT_SETTINGS" > "''${COPILOT_SETTINGS}.tmp" \
          && mv "''${COPILOT_SETTINGS}.tmp" "$COPILOT_SETTINGS"
      fi
    '';
  };
}
