---
name: init-skill
description: Generate an AGENTS.md file in the project root that describes the project's purpose, structure, and conventions. Use when user wants to initialize a project for agent use, create an AGENTS.md, bootstrap agent context, or mentions "init skill", "init project", or "agents.md".
---

# Init Skill

Generate an `AGENTS.md` file in the project root that gives any agent (or new contributor) a fast, accurate overview of the project.

## Process

1. **Explore the project** -- Use the Task tool with the `explore` agent to survey the project root. Gather:
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
- **Use the Task tool.** Exploration must go through the `explore` agent to keep context lean.

## Re-running

When invoked on a project that already has an `AGENTS.md`:

1. Read the existing file
2. Re-explore the project for changes
3. Ask the user whether to overwrite or merge
4. If merging, preserve any manually added sections and mark updated content with "(updated)"
