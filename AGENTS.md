# Agent Instructions: Nix Config Architecture & Tools

This project is a **Snowfall Lib-based NixOS/darwin/home-manager flake**. When working here, use the tools below in priority order. Nixpkgs and framework docs change fast — your training data lags, so lean on the live tools.

---

## 1. Graphify Graph (Codebase Discovery & Architecture)

Use the **Graphify** graph tools as your primary method for searching, exploring, and navigating the codebase. A pre-built graph exists at `graphify-out/graph.json`.

### When to Trigger:
- **Locating modules or hosts:** Find where a module (`modules/nixos/`, `modules/home/`, `modules/darwin/`, `modules/shared/`), system (`systems/`), or home (`homes/`) is defined.
- **Context gathering:** Entering an unfamiliar module to see what it imports, what options it declares, and what depends on it.
- **Pre-refactor review:** Before refactoring a module, evaluate blast radius — which hosts enable it, which other modules reference it.
- **Data flow tracing:** Track how an option flows from module declaration → host config → home config.

### Execution Instructions:
- **Find & Locate:** Use `search_nodes` to pinpoint modules matching a functional area (e.g., "hyprland", "stylix", "gaming").
- **Explore Connections:** Use `get_neighbors` on a module file to see its imports, exported options, and dependent hosts.
- **Trace Impact Radii:** Before changing a module, check its centrality. High-centrality nodes (e.g., `modules/shared/stylix`) affect many hosts — modify with care.
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
- **Snowfall Lib** auto-discovers `systems/`, `homes/`, `modules/<type>/<name>/default.nix`. Modules are namespaced as `my.<name>`.
- **Module types:** `nixos/`, `darwin/`, `home/`, `shared/` — keep cross-platform config in `shared/`.
- **Flake namespace** is `config` (set in `snowfall-lib.mkFlake` input `namespace`).

### Hosts

| Host | Arch | User | Role |
|------|------|------|------|
| `fenris` | `x86_64-linux` | `bjarne` | Primary desktop (Nvidia GPU, Hyprland, gaming, Razer, libvirtd, full setup) |
| `nixvm` | `x86_64-linux` | `dev` | VM/test host (Hyprland desktop, no Nvidia/gaming/Razer) |
| `nixwsl` | `x86_64-linux` | `dev` | WSL headless (no desktop, Docker, vscode-server, azure-cli) |
| `macbook` | `aarch64-darwin` | `bjarne` | Apple Silicon MacBook (nix-darwin, homebrew, Touch ID sudo) |

### NixOS Modules
- **`nixos/common`** — always-on basics: timezone Europe/Berlin, locale en_GB.UTF-8/de_DE, unfree, Nix caches (nix-community, claude-code, hyprland, xybschin), flakes, zsh, stateVersion 25.11
- **`nixos/common-desktop`** — shared desktop infra: US keyboard, NetworkManager, polkit, latest kernel, zramSwap, gparted, gnumake, wl-clipboard
- **`nixos/desktop`** — Hyprland (UWSM, xwayland), greetd/tuigreet, dconf
- **`nixos/nvidia`** — open driver, modesetting, powerManagement, VA-API, CUDA, nvtop, env vars
- **`nixos/gaming`** — Steam (gamemode), Lutris, Discord, Spotify, wowup-cf, protonup-rs
- **`nixos/razer`** — OpenRazer, polychromatic, auto DPI=1000 (fenris only)
- **`nixos/virtualisation`** — libvirtd, qemu_kvm, swtpm, SPICE USB, gnome-boxes
- **`nixos/1password`** — `programs._1password` + GUI with zen-bin
- **`nixos/audio`** — PipeWire (ALSA/32-bit/PulseAudio/JACK), easyeffects
- **`nixos/bluetooth`** — controller tweaks (FastConnectable, Experimental, JustWorksRepairing)
- **`nixos/boot`** — systemd-boot, limit 10, consoleMode=max
- **`nixos/gnome-keyring`** — GNOME Keyring + seahorse

### Darwin Modules
- **`darwin/common`** — timezone Europe/Berlin, unfree, Nix caches (claude-code), Touch ID sudo, homebrew (zap cleanup), zsh

### Home Manager Modules
- **`home/global`** — core pkgs (git, tree, unzip, gh, jq, htop, systemctl-tui). Imports fzf, zsh, nvim, tmux, lazygit, direnv, ranger. stateVersion 26.05
- **`home/coding-agents`** — Claude Code, OpenCode, GitHub Copilot CLI with MCP servers (git, nixos, firecrawl, context7). Fetches skills from github.com/xybschin/skills
- **`home/nvim`** — Neovim with LSP (nil, bash-language-server, lua-language-server, cmake-language-server, docker-language-server) and formatters (nixfmt, prettier, beautysh, stylua). Config symlinked from repo.
- **`home/tmux`** — stylix-colored theme, mode-indicator, prefix highlight, heavy pane borders
- **`home/terminals`** — Ghostty (Wayland/macOS) + Kitty
- **`home/1password`** — 1Password SSH agent bridge (WSL via socat/npiperelay)
- **`home/rvm-webcam`** — virtual background webcam via RobustVideoMatting (fenris only)
- **`home/waybar-audio-control`** — floating audio control widget (fenris only)

### Shared Modules (cross-platform)
- **`shared/stylix`** — dark polarity, custom "Koda Dark Minimal" scheme (base00: `#101010`), Inter + Terminess Nerd Font + Noto Color Emoji, macOS cursor (apple-cursor), breeze icons, wallpaper (artemis-ii-earth.jpg). Targets: hyprland (disabled — uses Lua), hyprpaper, zen-browser.
- **`shared/desktop`** — imports stylix, waybar, fonts, zen-browser, rofi, wayland-env, hyprpaper. Packages: nautilus, feh.
  - **`shared/desktop/wm/hyprland/`** — Lua config files, hyprlock (screenshot blur, time/date), hyprpolkitagent. Scripts: `auto-hide-wine-trays`, `monitor-config`, `rofi-launch`, `rofi-monitor-menu`.
  - **`shared/desktop/waybar/`** — bottom bar layout, stylix target disabled, playerctl. Scripts: `openrouter-credits`, `scrolling-playerctl`.
  - **`shared/desktop/rofi/`** — custom adi1090x type-1 style-10 theme, recolored with stylix colors.
  - **`shared/desktop/hyprpaper/`** — 14 single + 7 ultrawide/split wallpapers for multi-monitor.
  - **`shared/desktop/font.nix`** — Apple SF, Segoe UI, Nerd Fonts.
  - **`shared/desktop/zen-browser.nix`** — Zen browser flake integration.
  - **`shared/desktop/wayland-env.nix`** — Wayland env vars.
- **`shared/vscode`** — VSCode with gnome-libsecret, Vim extension, stylix color theme integration (fenris only)
- **`shared/ideavim`** — symlinks `.ideavimrc` from repo to `$HOME`

### Module-to-Host Usage

| Module | fenris | nixvm | nixwsl | macbook |
|--------|----------|-------|--------|---------|
| `nixos/common` | auto | auto | auto | — |
| `nixos/common-desktop` | yes | yes | — | — |
| `nixos/desktop` | yes | yes | — | — |
| `nixos/nvidia` | yes | — | — | — |
| `nixos/gaming` | yes | — | — | — |
| `nixos/razer` | yes | — | — | — |
| `nixos/virtualisation` | yes | — | — | — |
| `nixos/1password` | yes | yes | — | — |
| `nixos/gnome-keyring` | yes | — | — | — |
| `nixos/audio` | yes | yes | — | — |
| `nixos/bluetooth` | yes | yes | — | — |
| `nixos/boot` | yes | yes | — | — |
| `darwin/common` | — | — | — | auto |
| `shared/stylix` | full | full | headless-only | full |
| `shared/desktop` | yes | yes | — | — |
| `shared/vscode` | yes | — | — | — |
| `home/coding-agents` | yes | yes | yes | yes |
| `home/rvm-webcam` | yes | — | — | — |
| `home/waybar-audio-control` | yes | — | — | — |
| `home/terminals` | yes | — | — | yes |

### Stylix
- Custom theme at `modules/shared/stylix/koda-dark.yaml`
- Palette: background `#101010`, dark surfaces `#272727`, muted `#777777`, light fg `#b0b0b0`, white `#ffffff`, red `#ff5733`, orange `#c4a09a`, yellow `#d9ba73`, green `#4a4645`, cyan `#504d4b`, blue `#f0ece8`, purple `#b58e88`, brown `#666666`.

### Secrets
- sops-nix with GPG key `F28DC558F4792FCBCC4045141B6CFD2F494F4A52` (bjarne)
- Only secret file: `secrets/openrouter.env` — contains `OPENROUTER_API_KEY`
- Edit with: `sops secrets/openrouter.env`

### Rebuild Commands
```bash
make nixos host=<name>       # NixOS host (e.g. fenris, nixvm, nixwsl)
make darwin host=macbook     # Darwin host
make home user=<u> host=<h>  # Standalone home-manager
```
