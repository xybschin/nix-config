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

- **Snowfall Lib** auto-discovers `systems/`, `homes/`, `modules/<type>/<name>/default.nix`. Modules are namespaced as `my.<name>`.
- **Module types:** `nixos/`, `darwin/`, `home/`, `shared/` — keep cross-platform config in `shared/`.
- **Hosts:** `nixvidia` (desktop + Hyprland), `nixvm` (VM + Hyprland), `nixwsl` (WSL), `macbook` (darwin).
- **Stylix** does system-wide theming; theme file at `modules/shared/stylix/koda-dark.yaml`.
- **Secrets:** sops-nix with GPG; edit via `sops secrets/<file>`.
- **Rebuild commands:** `make nixos host=<name>`, `make darwin host=<name>`, `make home user=<name> host=<name>`.
