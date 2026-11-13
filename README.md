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

### Repo dev shell (devenv)

This repo edits itself inside a [devenv](https://devenv.sh) shell: `.envrc`
runs `use devenv` and `devenv.nix` lists the tools (`nil`, `nixfmt`,
`lua-language-server`, `sops`, …). The `devenv` CLI comes from the `devenv`
home feature, enabled on fenris and nixwsl. After cloning:

```bash
direnv allow    # or: devenv shell
```

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and stored in `secrets/`.

Only age keys are used — there is no PGP key. `.sops.yaml` lists the
recipients: `moonz`'s user key plus one system key per host. Each identity is
the single `AGE-SECRET-KEY-1…` line from an age key file, stored with mode
`600`:

| Identity | File | Consumed by |
| --- | --- | --- |
| `moonz` | `~/.config/sops/age/keys.txt` | `sops` CLI, `home/coding-agents.nix` |
| `fenris` | `/var/lib/sops-nix/key.txt` (root) | `nixos/brave-browser.nix` |
| `atlas` | `/var/lib/sops-nix/age/keys.txt` (root) | `hosts/atlas.nix` |

`SOPS_AGE_KEY_FILE=/path/to/keys.txt sops …` overrides the user identity for a
single invocation.

### Install a key on a host

Keys live in the 1Password vault `sops-nix`, one Document item per identity
(`moonz`, `fenris`, `atlas`) with the age key file uploaded as `keys.txt`. The
installer only distinguishes user keys from root keys; the item name is just
whatever to read from 1Password.

```bash
make age-key key=moonz kind=user                  # ~/.config/sops/age/keys.txt
make age-key key=fenris kind=root                 # /var/lib/sops-nix/key.txt, via sudo
make age-key key=fenris kind=root prefix=/mnt     # from the installer, before first boot
make age-key key=atlas kind=root dest=/var/lib/sops-nix/age/keys.txt
```

`prefix` is prepended to the destination (for a mounted root); `dest` replaces
the default destination entirely. `SOPS_VAULT` overrides the vault name.

Uses the installed `op`, else `nix shell nixpkgs#_1password-cli`; sign in
first (`op account add` + `eval "$(op signin)"`, or set
`OP_SERVICE_ACCOUNT_TOKEN`). It refuses to install a key whose public half is
not a recipient in `.sops.yaml`. Reinstalling a host with the same key needs no
re-encryption.

### Edit a secret

```bash
sops secrets/secrets.yaml
```
