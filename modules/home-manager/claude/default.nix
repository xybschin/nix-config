{
  lib,
  pkgs,
  copilot-cli,
  ...
}:

let
  # ──────────────────────────────────────────────
  # Shared source-of-truth values
  # ──────────────────────────────────────────────

  # Tools both CLIs should be able to run without prompting.
  # Claude Code uses "Bash(tool:*)" syntax; Copilot CLI uses bare tool names.
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
  sharedReasoningEffort = "high"; # maps to effortLevel in Claude, reasoning_effort in Copilot

  # Trusted home directories for Copilot CLI's workspace trust system
  copilotTrustedFolders = [
    "~" # trust the whole home directory (matches Claude's Read(/**))
  ];

  # ──────────────────────────────────────────────
  # Claude Code settings.json
  # ──────────────────────────────────────────────
  claudeConfig = builtins.toFile "claude-config.json" (
    builtins.toJSON {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";

      permissions = {
        allow =
          # Convert bare tool names → Claude's "Bash(tool:*)" syntax
          (map (t: "Bash(${t}:*)") sharedAllowedTools) ++ [
            # Claude agent self-invocation (required for CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS)
            "Bash(claude:*)"
            # File system (broad — personal machine)
            "Read(/**)"
            "Write(/**)"
            "Edit(/**)"
            "Glob(**)"
            "Grep"
            "WebFetch"
            "WebSearch"
          ];

        # Credentials that should never be touched
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

  # ──────────────────────────────────────────────
  # Copilot CLI settings.json
  # ──────────────────────────────────────────────
  copilotConfig = builtins.toFile "copilot-config.json" (
    builtins.toJSON {
      # Model: Claude Sonnet 4.6 is a good default; change to claude-opus-4-6
      # or gpt-4.1 (no premium cost) as needed. Use /model in-session to switch.
      model = "claude-sonnet-4-6";
      reasoning_effort = sharedReasoningEffort;
      theme = sharedTheme;
      render_markdown = true;
      banner = false;

      # Pre-approve the same tool set so Copilot doesn't prompt for each one.
      # Copilot uses bare tool names (no glob syntax).
      allowedTools = sharedAllowedTools;

      # Workspace trust: directories Copilot can access without prompting.
      trusted_folders = copilotTrustedFolders;
    }
  );

  skillDirs = builtins.attrNames (builtins.readDir ./config/skills);
  skillLinks =
    prefix:
    lib.listToAttrs (
      map (skill: {
        name = "${prefix}/${skill}";
        value.source = ./config/skills/${skill};
      }) skillDirs
    );
in
{
  home.packages = [
    pkgs.claude-code
    pkgs.github-copilot-cli
  ];

  home.shellAliases = {
    cc = "claude";
    cop = "copilot"; # adjust if the binary name differs
  };

  # ── Claude Code files ──────────────────────────
  home.file = {
    ".claude/CLAUDE.md".source = ./config/CLAUDE.md;
    ".copilot/instructions.md".source = ./config/CLAUDE.md;
  }
  // skillLinks ".claude/skills"
  // skillLinks ".copilot/skills";

  # ── Activation: merge both settings files ──────
  home.activation.ai-cli-settings-merge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    COPILOT_SETTINGS="$HOME/.copilot/settings.json"
    CLAUDE_CONFIG="${claudeConfig}"
    COPILOT_CONFIG="${copilotConfig}"
    JQ="${pkgs.jq}/bin/jq"

    $DRY_RUN_CMD mkdir -p "$HOME/.claude" "$HOME/.copilot"

    # ── Claude Code ──────────────────────────────
    if [ ! -f "$CLAUDE_SETTINGS" ]; then
      $DRY_RUN_CMD cp "$CLAUDE_CONFIG" "$CLAUDE_SETTINGS"
    else
      $DRY_RUN_CMD $JQ \
        --slurpfile mine "$CLAUDE_CONFIG" \
        '
          # Nix-managed scalars win; arrays are unioned to preserve user additions.
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

    # ── Copilot CLI ──────────────────────────────
    if [ ! -f "$COPILOT_SETTINGS" ]; then
      $DRY_RUN_CMD cp "$COPILOT_CONFIG" "$COPILOT_SETTINGS"
    else
      $DRY_RUN_CMD $JQ \
        --slurpfile mine "$COPILOT_CONFIG" \
        '
          # Nix-managed scalars win; allowedTools and trusted_folders are unioned.
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
}
