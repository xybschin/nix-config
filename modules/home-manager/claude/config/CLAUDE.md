# Claude Code — Base Policies

## How to Work
- Start complex tasks in plan mode (Shift+Tab twice). Iterate on the plan before implementing.
- During any planning activity, automatically apply the `grill-me` skill to stress-test the plan (surface assumptions, edge cases, trade-offs) before finalizing it. Skip grilling only when the user explicitly says so (e.g. "don't grill me", "skip grill", "no grilling").
- Verify your work before declaring it done — run tests, check types, lint.
- Use PRs for all non-trivial changes. Squash merge preferred. Direct push only for single-line hotfixes.
- Use subagents to offload research and keep the main context window focused.
- When sessions get long (3+ tasks or context compression), suggest checkpointing and starting fresh.

## Safety
- NEVER use `git commit --no-verify` without explicit user permission. Fix the issue first.
- NEVER run `./rebuild-nixos` or `nixos-rebuild` (requires sudo). Tell user to run it.
- NEVER create false or placeholder data — only real data.
- Claude CAN: edit nix configs, `nix flake check`, `nix build .#pkg`, `git add`

## Documentation
- ALWAYS ask before creating .md files. Propose: filename, purpose, alternative (existing file?)
- No temporal markers (NEW, Phase 2, Week 1). No hyperbole (enterprise-grade, robust, powerful)
- No emojis in docs, PR titles, PR descriptions, or commit messages. Keep tone strictly professional.
- Factual, technical, present tense, imperative mood

## Development
- Run tests before commits. Python: pytest. TypeScript: npm test. Nix: nix flake check
- Find root cause before fixing bugs — don't apply random fixes
- Read project files before making changes
- Before proposing new code: search the codebase first to verify it doesn't already exist
- Use devenv when project has devenv.nix; prefer system-level tools if devenv is heavy

## Git
- All changes via PRs. Review with `/review-pr` before merging.
- Commit messages follow Conventional Commits (`<type>(<scope>)?: <subject>`; types: feat, fix, refactor, docs, test, chore, build, ci, perf, style, revert). Subject in imperative mood, no trailing period, no emojis.
- Before composing a commit message, inspect `git status`/`git diff --staged` AND the current branch name (`git rev-parse --abbrev-ref HEAD`); use the branch name for issue/scope hints (e.g. `feat/<scope>-...`, `fix/<issue>-...`) but never invent a scope that isn't supported by the diff.
- Evaluate whether the staged changes belong in one commit. If they span multiple concerns (different scopes, mixing refactor + feature, unrelated files), split into smaller logical commits using `git add -p` or per-path `git add`. One commit = one coherent change.
- Amend previous commit only for small follow-up fixes on the same branch.
- Commit and push before testing deployed applications.

## Self-Improvement
After every correction or mistake, update the relevant CLAUDE.md or `.claude/rules/` file to prevent repeating it.
