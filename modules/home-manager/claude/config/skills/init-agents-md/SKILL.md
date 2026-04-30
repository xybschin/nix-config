---
name: init-agents-md
description: Generate an AGENTS.md file in the project root that describes the project's purpose, structure, and conventions. Use when the user wants to bootstrap agent context for a project, create or refresh an AGENTS.md, or mentions "init agents", "init project", or "agents.md".
---

# Init AGENTS.md

Generate an `AGENTS.md` file in the project root that gives any agent (or new contributor) a fast, accurate overview of the project.

## Process

1. **Explore the project** -- Survey the project root using available exploration tools. Prefer an `explore` subagent if one is configured; otherwise use grep/glob/view directly. Gather:
   - Top-level directory structure (one level deep)
   - Key config files (package.json, Cargo.toml, go.mod, flake.nix, pyproject.toml, etc.)
   - README or existing documentation
   - Source entry points and main modules
   - Test setup and CI config if present

2. **Identify the essentials** -- From what you found, determine:
   - **What** the project is (one-sentence purpose)
   - **Tech stack** (language, framework, key dependencies)
   - **Project layout** (which directories contain what)
   - **Build / run / test commands** (how to work with the project)
   - **Conventions** (naming, patterns, architecture style -- only if clearly evident)

3. **Write `AGENTS.md`** -- Create the file in the project root using the format below. Be concise and factual. Do not invent information that is not evident from the codebase.

4. **Report** -- Tell the user what you wrote and where.

## Output Format

Write `AGENTS.md` in the workspace root with this structure:

```md
# AGENTS.md

## Purpose

[One to three sentences describing what this project does.]

## Tech Stack

- **Language:** [e.g. TypeScript, Rust, Go, Nix]
- **Framework:** [e.g. Next.js, Axum, none]
- **Key dependencies:** [list only the most important ones]

## Project Layout

```
directory/        # what it contains
another-dir/      # what it contains
```

## Build & Run

```sh
# build
<command>

# run
<command>

# test
<command>
```

## Conventions

- [Only list conventions that are clearly evident from the code]
```

Omit any section where the information is not available or not applicable. Do not guess.

## Rules

- **Do not hallucinate.** Every statement in AGENTS.md must be backed by something you observed in the project files. If you are unsure, omit it.
- **Be concise.** The file should be scannable in under 30 seconds. Aim for under 60 lines.
- **No opinions.** Describe what IS, not what should be.
- **Respect existing files.** If an `AGENTS.md` already exists, read it first and ask the user whether to overwrite or update it.
- **Use exploration efficiently.** If an `explore` subagent is available, prefer it to keep context lean; otherwise batch grep/glob/view calls.

## Re-running

When invoked on a project that already has an `AGENTS.md`:

1. Read the existing file
2. Re-explore the project for changes
3. Ask the user whether to overwrite or merge
4. If merging, preserve any manually added sections and mark updated content with "(updated)"
