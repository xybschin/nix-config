# AGENTS.md -- NixOS / Home Manager Flake Configuration

## Project Overview

Flake-based NixOS and Home Manager configuration managing multiple hosts and users.
All files are Nix (`.nix`). There are no custom module options -- every file is a
configuration-only module that directly sets NixOS or Home Manager option values.

## Repository Structure

```
flake.nix                   # Flake entrypoint: inputs, outputs, system/user definitions
lib/mksystem.nix            # Helper: construct full NixOS system configuration
lib/mkstandalone.nix        # Helper: construct standalone Home Manager configuration
hosts/<hostname>/default.nix       # Per-host NixOS config (imports modules/nixos/)
hosts/users/<user>/default.nix     # Per-user system-level config (account, shell, groups)
home-manager/<user>/default.nix    # Per-user HM config (imports modules/home-manager/)
modules/nixos/              # NixOS modules (boot, audio, nvidia, bluetooth, etc.)
modules/home-manager/       # HM modules (shell, editor, desktop, tools, etc.)
Makefile                    # Build commands
```

## Build Commands

```bash
make build-host host=<hostname>   # Rebuild NixOS system config (requires sudo)
make build-user user=<username>   # Rebuild Home Manager user config
```

Both set `CONFIG_ROOT` automatically and pass `--impure` (required for `configRoot`).

## Validation, Linting, and Formatting

```bash
nix flake check --no-build                          # Fast syntax/eval check
nixos-rebuild dry-build --impure --flake .#<host>    # Dry-build NixOS config
home-manager build --impure --flake .#<user>         # Dry-build Home Manager config
nixfmt **/*.nix                                      # Format all Nix files
```

There is no test suite. Validation is done through `nix flake check` and dry builds.
This project uses **`nixfmt`** (the official RFC-style formatter). Format all files
before committing. All style rules below reflect `nixfmt` output.

## Code Style Guide

### Indentation

2 spaces. No tabs. No exceptions.

### Function Arguments

Single-line for 1-2 named arguments: `{ pkgs, ... }:`

Multi-line for 3+ named arguments, one per line, `...` always last:
```nix
{
  config,
  pkgs,
  lib,
  ...
}:
```

### Attribute Sets

One attribute per line. `enable = true;` first in program/service blocks.
Use dot notation for concise single-value nesting (`nixpkgs.config.allowUnfree = true;`).
```nix
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
};
```

### Lists

Single-line for 0-1 items (`[ ]`, `[ pkgs.nautilus ]`). Multi-line for 2+ items,
one item per line.

### Package References

Use `with pkgs; [ ... ]` for lists of 2+ packages. Use `pkgs.foo` for single
package references (`package = pkgs.nix;`).

### `inherit`

Single-line for 1-2 names (`inherit system specialArgs;`).
Multi-line for 3+ names, each on its own line, `;` on its own line:
```nix
inherit
  inputs
  nixpkgs
  overlays
  ;
```

### `let ... in`

`let` and `in` at the same indentation level. Bindings indented 2 spaces.
`in` is always on its own line, followed by `{` on the next line.

### `with` Expressions

Only use `with` for package lists (`with pkgs; [ ... ]`). Never use `with` at
module top-level or in attribute set contexts.

### `lib` Usage

Always qualify `lib` functions -- write `lib.mkIf`, never `mkIf` via `with lib;`.
Use `lib` functions sparingly and only when necessary (e.g., `lib.mkIf` for
conditional config, `lib.mkBefore` for ordering).

### Imports

One path per line, using relative paths. Directory imports resolve to `default.nix`.

### Comments and Strings

Use `#` line comments only. Use section-header comments to group items in lists.
For multi-line strings, use `'' ... ''` syntax, indented to match surrounding context.
String interpolation with `${ ... }` is used freely inside multi-line strings.

## Module Conventions

- **One concern per file**: each module handles exactly one tool, service, or feature.
- **`default.nix` as aggregator**: directory-level `default.nix` files aggregate
  sub-modules via `imports`.
- **No custom options**: do not define `mkOption` or `mkEnableOption`. Set config
  values directly.
- **NixOS vs Home Manager separation**: system-level config in `modules/nixos/`,
  user-level config in `modules/home-manager/`.
- **`configRoot`**: runtime env var (`CONFIG_ROOT`) for out-of-store symlinks.
  Requires `--impure` flag. Used for live-editing configs (e.g., Neovim) without
  rebuilding.

## Adding New Configuration

**New module**: create `modules/home-manager/<name>.nix` (or `modules/nixos/<name>.nix`
for system modules), then add the import path to the relevant user/host config.

**New host**: create `hosts/<hostname>/default.nix`, add `nixosConfigurations.<hostname>`
to `flake.nix` using `mkSystem`.

**New user**: create `home-manager/<user>/default.nix` and
`hosts/users/<user>/default.nix`, add to `flake.nix` outputs.

## Key Flake Inputs

- `nixpkgs`: nixos-unstable channel
- `home-manager`: follows nixpkgs
- `nixos-wsl`: WSL support
- `neovim-nightly-overlay`: nightly Neovim builds
- `zen-browser`: Zen browser flake
- `opencode`: OpenCode Nix overlay
