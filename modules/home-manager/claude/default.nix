{
  config,
  lib,
  pkgs,
  ...
}:

let
  myConfig = builtins.toFile "claude-config.json" (
    builtins.toJSON {
      permissions = {
        allow = [
          "Bash(git:*)"
          "Bash(gh:*)"
          "Bash(nix:*)"
          "Bash(nix-build:*)"
          "Bash(nix-instantiate:*)"
          "Bash(nix-locate:*)"
          "Bash(nix-prefetch-url:*)"
          "Bash(nix-shell:*)"
          "Bash(nix-store:*)"
          "Bash(nixos-option:*)"
          "Bash(nixos-rebuild list-generations:*)"
          "Bash(nixpkgs-fmt:*)"
          "Bash(alejandra:*)"
          "Bash(devenv:*)"
          "Bash(direnv:*)"
          "Bash(home-manager:*)"
          "Bash(nom:*)"
          "Bash(nvd:*)"
          "Bash(statix:*)"
          "Bash(node:*)"
          "Bash(npm:*)"
          "Bash(npx:*)"
          "Bash(bun:*)"
          "Bash(python:*)"
          "Bash(python3:*)"
          "Bash(pytest:*)"
          "Bash(uv:*)"
          "Bash(uvx:*)"
          "Bash(gitleaks detect:*)"
          "Bash(pre-commit:*)"
          "Bash(ruff:*)"
          "Bash(shellcheck:*)"
          "Bash(shfmt:*)"
          "Bash(awk:*)"
          "Bash(basename:*)"
          "Bash(bat:*)"
          "Bash(cat:*)"
          "Bash(cd:*)"
          "Bash(cloc:*)"
          "Bash(command:*)"
          "Bash(cp:*)"
          "Bash(cut:*)"
          "Bash(delta:*)"
          "Bash(df:*)"
          "Bash(diff:*)"
          "Bash(dig:*)"
          "Bash(dirname:*)"
          "Bash(du:*)"
          "Bash(dust:*)"
          "Bash(echo:*)"
          "Bash(env:*)"
          "Bash(eza:*)"
          "Bash(fastfetch:*)"
          "Bash(fd:*)"
          "Bash(file:*)"
          "Bash(find:*)"
          "Bash(getconf:*)"
          "Bash(glow:*)"
          "Bash(grep:*)"
          "Bash(head:*)"
          "Bash(host:*)"
          "Bash(hyperfine:*)"
          "Bash(jless:*)"
          "Bash(jq:*)"
          "Bash(journalctl:*)"
          "Bash(kill:*)"
          "Bash(ldd:*)"
          "Bash(lizard:*)"
          "Bash(ls:*)"
          "Bash(lsblk:*)"
          "Bash(lscpu:*)"
          "Bash(lsof:*)"
          "Bash(lspci:*)"
          "Bash(lsusb:*)"
          "Bash(mkdir:*)"
          "Bash(mv:*)"
          "Bash(pgrep:*)"
          "Bash(ping:*)"
          "Bash(printenv:*)"
          "Bash(printf:*)"
          "Bash(procs:*)"
          "Bash(ps:*)"
          "Bash(pwd:*)"
          "Bash(readlink:*)"
          "Bash(rg:*)"
          "Bash(sed:*)"
          "Bash(sleep:*)"
          "Bash(sort:*)"
          "Bash(ss:*)"
          "Bash(stat:*)"
          "Bash(tail:*)"
          "Bash(tee:*)"
          "Bash(test:*)"
          "Bash(tokei:*)"
          "Bash(touch:*)"
          "Bash(tr:*)"
          "Bash(tree:*)"
          "Bash(uname:*)"
          "Bash(uniq:*)"
          "Bash(unzip:*)"
          "Bash(wc:*)"
          "Bash(which:*)"
          "Bash(who:*)"
          "Bash(xargs:*)"
          "Bash(xxd:*)"
          "Bash(yq:*)"
          "Bash(curl:*)"
          "Bash(claude:*)"
          "Read(/**)"
          "Write(/**)"
          "Edit(/**)"
          "Glob(**)"
          "Grep"
          "WebFetch"
          "WebSearch"
        ];
      };

      enabledPlugins = {
        "context7@claude-plugins-official" = true;
        "code-review@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "pr-review-toolkit@claude-plugins-official" = true;
        "plugin-dev@claude-plugins-official" = true;
        "feature-dev@claude-plugins-official" = true;
        "frontend-design@claude-plugins-official" = true;
        "document-skills@anthropic-agent-skills" = true;
        "code-simplifier@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
        "ralph-loop@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "claude-md-management@claude-plugins-official" = true;
        "explanatory-output-style@claude-plugins-official" = true;
        "claude-code-setup@claude-plugins-official" = true;
        "hookify@claude-plugins-official" = true;
        "learning-output-style@claude-plugins-official" = true;
      };

      alwaysThinkingEnabled = true;

      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
    }
  );
in
{
  home.file = {
    ".claude/CLAUDE.md".source = ./config/CLAUDE.md;
  }
  //
    # Link each skill directory individually, keeping the parent writable
    lib.listToAttrs (
      map (skill: {
        name = ".claude/skills/${skill}";
        value = {
          source = ./config/skills/${skill};
        };
      }) (builtins.attrNames (builtins.readDir ./config/skills))
    );

  home.activation.claude-settings-merge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS="$HOME/.claude/settings.json"
    MY_CONFIG="${myConfig}"

    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    if [ ! -f "$SETTINGS" ]; then
      $DRY_RUN_CMD cp "$MY_CONFIG" "$SETTINGS"
    else
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --slurpfile mine "$MY_CONFIG" \
        '
          .permissions.allow = ((.permissions.allow // []) + $mine[0].permissions.allow | unique) |
          .permissions.deny  = ((.permissions.deny  // []) + ($mine[0].permissions.deny // []) | unique) |
          .enabledPlugins = ($mine[0].enabledPlugins * (.enabledPlugins // {})) |
          .alwaysThinkingEnabled = $mine[0].alwaysThinkingEnabled |
          .env = ($mine[0].env * (.env // {}))
        ' "$SETTINGS" > "''${SETTINGS}.tmp" \
        && mv "''${SETTINGS}.tmp" "$SETTINGS"
    fi
  '';
}
