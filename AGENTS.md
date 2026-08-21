# Agent Instructions: Nix Config Architecture & Tools

This project is a **flake-parts/import-tree (dendritic) NixOS/darwin/home-manager flake**. Every `.nix` file under [`config/`](config/) is auto-imported as a module (`config.core.nix` declares the option tree, `config/outputs.nix` builds the configurations). When working here, use the tools below in priority order. Nixpkgs and framework docs change fast — your training data lags, so lean on the live tools.

---

## 1. Graphify Graph (Codebase Discovery & Architecture)

Use the **Graphify** graph tools as your primary method for searching, exploring, and navigating the codebase. A pre-built graph exists at `graphify-out/graph.json`.

### When to Trigger:
- **Locating modules or hosts:** Find where a module (`config/nixos/`, `config/home/`, `config/darwin/`, `config/shared/`), host (`config/hosts/`), or feature is defined.
- **Context gathering:** Entering an unfamiliar module to see what it imports, what options it declares, and what depends on it.
- **Pre-refactor review:** Before refactoring a module, evaluate blast radius — which hosts enable it, which other modules reference it.
- **Data flow tracing:** Track how an option flows from feature declaration → host config → home config.

### Execution Instructions:
- **Find & Locate:** Use `search_nodes` to pinpoint modules matching a functional area (e.g., "hyprland", "stylix", "gaming").
- **Explore Connections:** Use `get_neighbors` on a module file to see its imports, exported options, and dependent hosts.
- **Trace Impact Radii:** Before changing a module, check its centrality. High-centrality nodes (e.g., `config/shared/stylix.nix`) affect many hosts — modify with care.
- **Stale Cache Warning:** The graph server reads `graph.json` at startup. After structural changes, rebuild with `graphify build .` and restart the session.

---

## 2. NixOS Tool (Packages, Options, Channels, Flakes)

Use the **`nixos_nix`** tool as your primary source for nixpkgs, NixOS/home-manager/darwin options, flake inputs, and /nix/store paths. Supplement with **`nixos_nix_versions`** for package version history.

### When to Trigger:
- Adding a new package — verify it exists in nixpkgs (channel: `unstable`) and check its attribute path.
- Enabling a NixOS/home-manager/darwin option — search and inspect option details.
- Bumping or adding a flake input — list current inputs and explore available inputs.
- Debugging a build failure — read files from /nix/store or list store paths.
- Checking whether a specific package version is available — use `nixos_nix_versions`.

### Common Queries:
```
nixos_nix(action="search", query="<package>")               # search packages
nixos_nix(action="info", query="<attrpath>")                  # package details
nixos_nix(action="search", query="<option>", type="options") # search NixOS options
nixos_nix(action="info", query="<option>", type="option")     # option details
nixos_nix(action="search", query="<option>", source="home-manager")
nixos_nix(action="search", query="<option>", source="darwin")
nixos_nix(action="flake-inputs")                              # list current flake inputs
nixos_nix(action="store", type="ls", query="/nix/store/...")  # list store paths
nixos_versions(package="<pkg>", version="<ver>")              # version history
```

---

## 3. Web Fetch & Search (Fallback for Docs & Niche URLs)

When the above tools can't answer the question, use **`webfetch`** (single URL → markdown) or **`websearch`** (query → results).

### When to Trigger:
- Researching a niche GitHub issue, blog post, or user-provided URL.
- Looking up documentation for a tool not covered by nixpkgs (e.g., a specific Hyprland wiki page, a Waybar module).
- Checking the upstream README of a flake input.

---

## 4. Available Skills

Load these with the `skill` tool when the task matches:

| Skill | When to use |
|-------|-------------|
| `graphify` | Codebase questions, architecture queries, file relationships |
| `commit` | User says "commit", "create commit", or `/commit` |
| `domain-modeling` | Pinning down domain terminology, recording ADRs |
| `improve-codebase-architecture` | Finding refactoring opportunities, consolidation |
| `implement` | Implementing work from a spec or tickets |
| `wayfinder` | Planning large multi-session work |

---

## 5. Workflow Priority Sequence

When tackling a request:

1. **Map with Graphify** — `search_nodes` / `get_neighbors` to find relevant files and their dependencies.
2. **Read local code** — open the identified files to understand current logic.
3. **Query Nix tools** — use `nixos_nix` / `nixos_nix_versions` for packages, options, and store paths.
4. **Fallback to web** — `webfetch` or `websearch` for external docs, issues, or blogs.

---

## 6. Repo-Specific Conventions

### Architecture
- **Dendritic pattern:** [`flake.nix`](flake.nix) feeds every `.nix` file under [`config/`](config/) into flake-parts via `inputs.import-tree ./config`. Directories prefixed with `_` are **excluded** from auto-import (used for submodules/assets/data).
- **`config/core.nix`** declares the whole option tree: `config.my.configRoot` (repo path for out-of-store symlinks), `config.my.features.{nixos,home,darwin}` (`attrsOf deferredModule` — feature modules), and `config.my.hosts` (submodule with `system`/`username`/`isWsl` and per-kind `features`/`extraModules`/`configuration`).
- **`config/outputs.nix`** builds `nixosConfigurations` (x86_64-linux hosts), `darwinConfigurations` (aarch64-darwin), and `homeConfigurations` (`${username}@${host}` for every host). Also injects the home-manager integration modules and the sops-nix home module into both integrated and standalone homes.
- **Feature modules:** a file like `config/home/terminals.nix` defines `config.my.features.home.terminals = { pkgs, ... }: { ... };`. The **outer** lambda only receives flake-parts args (`config`, `lib`, `inputs`) — **`pkgs` is NOT available there**. Any `pkgs`/`hostUser`/`configRoot` usage must live **inside** the feature value lambda, which is evaluated in the home-manager/NixOS/darwin context (where those args exist). Same rule applies to `nixos.configuration` / `home.configuration` values in hosts.
- Feature-references-feature (e.g. `config/shared/desktop.nix` importing the `shared.stylix` module) requires an attrset module `{ imports = [ ... ]; }` — a bare list is rejected.
- **Eval gotchas:** import-tree only sees git-tracked files (must `git add` before evaluating). `builtins.getEnv` returns `""` in pure eval, so configRoot uses `CONFIG_ROOT` env with `PWD` fallback and evaluations run with `--impure` (the Makefile does this).
- All `nixpkgs.config.allowUnfree = true` lives both in `config/nixos/common.nix` (system) and in the `homeUser` wrapper in `config/outputs.nix` (home), because home-manager's pkgs is a separate instance.

### Hosts

| Host | Arch | User | Role |
|------|------|------|------|
| `fenris` | `x86_64-linux` | `moonz` | Primary desktop (AMD GPU, Hyprland, gaming, Razer, libvirtd, full setup) |
| `nixwsl` | `x86_64-linux` | `dev` | WSL headless (Docker, vscode-server, azure-cli, coding agents) |
| `macbook` | `aarch64-darwin` | `bjarne` | Apple Silicon MacBook (nix-darwin, homebrew, Touch ID sudo) |

### NixOS Features (`config/nixos/`)
- **`common`** — always-on basics: timezone Europe/Berlin, locale en_GB.UTF-8/de_DE, unfree, Nix caches (nix-community, claude-code, hyprland, xybschin), flakes, zsh, stateVersion 25.11, stylix overlays disabled
- **`common-desktop`** — shared desktop infra: US keyboard, NetworkManager, polkit, zramSwap, gparted, gnumake, wl-clipboard
- **`desktop`** — Hyprland (UWSM, xwayland), greetd/tuigreet, dconf
- **`gaming`** — Steam (gamemode), Lutris (openldap FHS fix), Discord, Spotify, wowup-cf, protonup-rs
- **`razer`** — OpenRazer, polychromatic, auto DPI=1000 (fenris only)
- **`logiops`** — LogiOps HID++ driver for Logitech devices; MX Master 3S: DPI=1000, SmartShift on (threshold 30), HiRes scroll (fenris only)
- **`virtualisation`** — libvirtd, qemu_kvm, swtpm, SPICE USB, gnome-boxes (fenris only)
- **`1password`** — `programs._1password` + GUI with zen-bin
- **`audio`** — PipeWire (ALSA/32-bit/PulseAudio/JACK), easyeffects
- **`bluetooth`** — controller tweaks (FastConnectable, Experimental, JustWorksRepairing)
- **`boot`** — systemd-boot, configLimit 1, consoleMode=max
- **`gnome-keyring`** — GNOME Keyring + seahorse
- **`usb-auto-mount`** — udisks2, gvfs, ntfs3g

### Darwin Features (`config/darwin/`)
- **`common`** — timezone Europe/Berlin, unfree, Nix caches (claude-code), Touch ID sudo, homebrew (zap cleanup), zsh

### Home Features (`config/home/`)
- **`global`** — core pkgs (git, tree, unzip, gh, jq, htop, systemctl-tui). Imports `_global/{fzf,zsh,nvim,herdr,lazygit,direnv,ranger}`. Sets a `stylix.base16Scheme` mkDefault (base16 Vesper from `pkgs.base16-schemes`) so herdr/zsh/waybar color interpolation resolves even when theming is off. stateVersion 26.05
- **`coding-agents`** — Claude Code, OpenCode, GitHub Copilot CLI with MCP servers (git, nixos, firecrawl, context7). Fetches skills from github.com/xybschin/skills
- **`1password`** — 1Password SSH agent bridge (WSL via socat/npiperelay)
- **`terminals`** — Ghostty (Wayland/macOS) + Kitty
- **`mangohud`** — session-wide MangoHud (fenris only)
- **`waybar-audio-control`** — floating audio control widget (fenris only)
- **`rvm-webcam`** — virtual background webcam via RobustVideoMatting (fenris only)

### Shared Features (`config/shared/`)
- **`stylix.nix`** — dark polarity, base16 Vesper scheme from `pkgs.base16-schemes` (`share/themes/vesper.yaml`), Inter + Terminess Nerd Font + Noto Color Emoji, macOS cursor (apple-cursor), breeze icons, wallpaper (artemis-ii-earth.jpg). Targets: hyprland (disabled — uses Lua), hyprpaper. Imported only by `shared.desktop`.
- **`desktop.nix`** — imports `stylix`, `_desktop/{waybar,font.nix,zen-browser.nix,rofi,wayland-env.nix,hyprpaper}`. Packages: nautilus, feh, udiskie, dconf automount.
- **`wm-hyprland.nix`** — `_desktop/wm/hyprland/` Lua config files (mkOutOfStoreSymlink), stylix-generated `hypr/colors.lua`, hyprlock, hyprpolkitagent. Scripts: `rofi-launch`, `rofi-monitor-menu`.
- **`vscode.nix`** — VSCode with gnome-libsecret, Vim extension, stylix color theme integration (fenris only)
- **`_desktop/waybar/`** — bottom bar (stylix colors, playerctl via `scrolling-playerctl`), sops secret `openrouter` (EnvironmentFile after `sops-nix.service`).
- **`_desktop/rofi/`** — custom adi1090x type-1 style-10 theme, recolored with stylix colors.
- **`_desktop/hyprpaper/`** — 14 single + 7 ultrawide/split wallpapers for multi-monitor.
- **`_desktop/font.nix`** — Apple SF, Segoe UI, Nerd Fonts.
- **`_desktop/zen-browser.nix`** — Zen browser flake integration; unfree addons (onepassword, improved-tube, untrap-for-youtube) are vendored locally because the firefox-addons NUR flake imports its own nixpkgs without an allowUnfree config.
- **`_desktop/wayland-env.nix`** — Wayland env vars.

### Feature-to-Host Usage

| Feature | fenris | nixwsl | macbook |
|---------|--------|--------|---------|
| `nixos.common` | yes | yes | — |
| `nixos.common-desktop` | yes | — | — |
| `nixos.desktop` | yes | — | — |
| `nixos.gaming` | yes | — | — |
| `nixos.razer` | yes | — | — |
| `nixos.logiops` | yes | — | — |
| `nixos.virtualisation` | yes | — | — |
| `nixos.1password` | yes | — | — |
| `nixos.gnome-keyring` | yes | — | — |
| `nixos.audio` | yes | — | — |
| `nixos.bluetooth` | yes | — | — |
| `nixos.boot` | yes | — | — |
| `nixos.usb-auto-mount` | yes | — | — |
| `darwin.common` | — | — | yes |
| `home.global` | yes | yes | yes |
| `home.1password` | yes | yes | yes |
| `home.coding-agents` | yes | yes | yes |
| `home.terminals` | yes | — | yes |
| `home.mangohud` | yes | — | — |
| `home.waybar-audio-control` | yes | — | — |
| `home.rvm-webcam` | yes | — | — |
| `shared.stylix` | yes | — | — |
| `shared.desktop` | yes | — | — |
| `shared.desktop.wm.hyprland` | yes | — | — |
| `shared.vscode` | yes | — | — |

Host-specific extras live in `config/hosts/_fenris/` (hardware, hyprland-user Lua, scripts) and are wired via `extraModules`/`xdg.configFile` in `config/hosts/fenris.nix`.

### Stylix
- Scheme: base16 Vesper (by FormalSnake), loaded from `pkgs.base16-schemes` (`share/themes/vesper.yaml`) — no vendored YAML needed.
- Palette: background `#101010`, surfaces `#232323`/`#222222`, muted `#333333`, fg `#b7b7b7`, accents are muted red `#de6e6e`, sand `#dab083`, peach `#ffc799`, teal `#5f8787`, green-teal `#60a592`, blue-gray `#8eaaaa`, rose `#d69094`.

### Secrets
- sops-nix with GPG key `F28DC558F4792FCBCC4045141B6CFD2F494F4A52` (bjarne)
- Only secret file: `secrets/openrouter.env` — contains `OPENROUTER_API_KEY`
- Edit with: `sops secrets/openrouter.env`

### Rebuild Commands
```bash
make nixos host=<name>       # NixOS host (e.g. fenris, nixwsl)
make darwin host=macbook     # Darwin host
make home user=<u> host=<h>  # Standalone home-manager (e.g. make home user=moonz host=fenris)
```
