# NixOS Configuration

Flake-based NixOS, Darwin, and Home Manager configuration using the
[dendritic pattern](https://github.com/denful/import-tree): every `.nix` file
under [`config/`](config/) is auto-imported as a flake-parts module (dirs
prefixed with `_` are excluded). Modules define feature sets under
`config.my.features.*`, hosts under `config.my.hosts`, and
[`config/outputs.nix`](config/outputs.nix) wires them into
`nixosConfigurations` / `darwinConfigurations`; each host's Home Manager
configuration is integrated into its system.

## Usage

### Rebuild NixOS Host

```bash
make nixos host=<hostname>
```

### Rebuild Darwin Host

```bash
make darwin host=<hostname>
```

### WSL note (1password SSH agent)

On WSL, the 1Password SSH bridge (`config/home/1password.nix`) forwards the
Windows OpenSSH agent via `npiperelay.exe`. This binary must be on the Windows
`PATH` (i.e. reachable from WSL as `npiperelay.exe`).

### Check every configuration evaluates

```bash
make check
```

### Per-project dev shells (devenv)

The `devenv` CLI ships as a home feature (`devenv`, enabled on fenris and
nixwsl). Each project carries its own `devenv.nix`; shared, pre-configured
language stacks (go, typescript, dotnet) are exported by this flake as
`devenvModules`.

```bash
cd ~/src/my-project
devenv init --include-envrc   # scaffolds devenv.nix, devenv.yaml, .envrc
```

Point the project at this repo, then import the stack you need:

```yaml
# devenv.yaml
inputs:
  nix-config:
    url: github:xybschin/nix-config
```

```nix
# devenv.nix
{ inputs, ... }: {
  imports = [ inputs.nix-config.devenvModules.typescript ];
}
```

Then `direnv allow` (or `devenv shell`). The `.envrc` needs
`eval "$(devenv direnvrc)"` before `use devenv` — `devenv init --include-envrc`
writes it for you. `devenv update` bumps the lock when the shared modules
change. Note: devenv builds environments with its own pinned nixpkgs; pin a
`nixpkgs` input in `devenv.yaml` if a project needs a different one.

This repo uses its own devenv: `direnv allow` loads `devenv.nix` (nil, nixfmt,
sops, mcp-nixos). The devenv installs no coding agent. The `nixos` MCP server
is project-scoped — `.opencode/opencode.json` runs `mcp-nixos` from the devenv
shell's `PATH` — so it is only available inside this repo's shell, not in the
global agent config.

## Claude Code releases

`claude-code` is overlaid (`config/_overlays/claude-code.nix`) to follow
Anthropic's release feed: the newest release is resolved while the
configuration is evaluated, so a rebuild lands on the current release instead
of the one nixpkgs pins.

```bash
make nixos host=<hostname>   # picks up the newest release
```

The lookup happens during evaluation, so it needs `--impure` — the Makefile
and `make check` already pass it. Pin the release with an environment
variable:

```bash
CLAUDE_CODE_VERSION=2.1.300 make nixos host=<hostname>   # a specific release
CLAUDE_CODE_VERSION=nixpkgs  make nixos host=<hostname>   # nixpkgs' version, no network
```

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and stored in `secrets/`.

### Edit a secret

```bash
nix shell nixpkgs#sops nixpkgs#gnupg -c sops secrets/<file>.env
```

### User secrets (Home Manager)

`secrets/home.yaml` holds secrets for the `coding-agents` feature (currently
`context7_api_key`). It is encrypted to the sops PGP key only, so one key
decrypts it on every machine. The private key lives in 1Password
("sops GPG private key", vault Private); import it once per machine:

```bash
op item get 3f3fu7fw5jggewxcuoagozxjvm --field sops-gpg-private-key.asc:text | gpg --import
```

The key must not need a passphrase prompt at activation (sops-nix runs
`gpg` non-interactively).
