# AGENTS.md

Declarative NixOS / nix-darwin / Home Manager configuration for four hosts,
evaluated as one flake. Domain vocabulary lives in
[`GLOSSARY.md`](GLOSSARY.md) — use its terms when naming new options,
features, or docs. Rebuild and secrets commands: [`README.md`](README.md).

## Model

`flake.nix` feeds `config/` to import-tree: **every `.nix` file under
`config/` is an auto-imported flake-parts module**. Paths starting with `_`
are excluded — they hold private fragments that plain `.nix` files reference
by relative path.

Modules register against the schema in `config/core.nix`:

- `config.my.features.{nixos,home,darwin}.<name>` — one named deferred module
- `config.my.hosts.<name>` — machine with `system`, `username`, and the
  feature *names* it opts into (plus `extraModules` and `configuration`)

`config/outputs.nix` resolves each host's names through the registry into
`nixosConfigurations` and `darwinConfigurations`, with each host's Home
integrated as a Home Manager module.

Flow: a file lands under `config/` → registers a feature or host → a host
lists the feature by name → `outputs.nix` maps names to modules →
`nixosSystem` / `darwinSystem` evaluates.

## Conventions

- A feature file registers exactly one feature, two layers deep. The outer
  function runs at flake-eval time; the inner one is the module a host
  receives:

  ```nix
  { ... }:                              # flake-parts module (auto-imported)
  {
    config.my.features.nixos.<name> =   # registration
      { pkgs, inputs, ... }:            # deferred module (host opt-in)
      { ... };
  }
  ```

- Feature modules may consume other features through the registry instead of
  relative imports: `config.my.features.home."shared.stylix"`.

- Features receive `inputs`, `configRoot`, and `hostUser` as module args
  (`isWsl` on home modules) — declared in `config/outputs.nix`.

- `shared/` features use dotted names, quoted:
  `"shared.desktop"`, `"shared.desktop.wm.hyprland"`.

- Underscore paths are opt-in only: `config/hosts/_<host>/` holds per-host
  hardware/disko/fragments, `config/_lib/` holds pure helpers, never
  modules. Nothing outside `config/` is auto-imported.

## Editing

- **New NixOS feature**: add `config/nixos/<name>.nix` registering
  `config.my.features.nixos.<name>`; opt hosts in by appending the name to
  `host.nixos.features` in `config/hosts/<host>.nix`.
- **New home feature**: same under `config/home/<name>.nix` and
  `host.home.features`.
- **New host**: add `config/hosts/<name>.nix` declaring
  `config.my.hosts.<name>`; put machine-only files in
  `config/hosts/_<name>/`.

## Verify

```bash
make check
```

Evaluates every nixos/darwin/home configuration and fails on the first
broken one. It is the done gate: CI runs it on every PR to `main`, and a
change is not complete until it passes. Evaluation is impure — `make` exports
`CONFIG_ROOT` and `NIXPKGS_ALLOW_UNFREE`; raw `nix eval` needs those plus
`--impure`.

## Secrets

Encrypted with sops-nix under `secrets/`, key rules in `.sops.yaml` (your
PGP key, atlas's age key). Edit only via the `sops` command in
[`README.md`](README.md); decrypted values never belong in the repo.

## Submodule

`config/home/_global/nvim/config` is a git submodule. `make` targets run
`git submodule update --init --recursive` first; run it manually if files
there are missing after a clone.
