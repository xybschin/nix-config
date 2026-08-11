# NixOS Configuration

Flake-based NixOS, Darwin, and Home Manager configuration using the
[dendritic pattern](https://github.com/denful/import-tree): every `.nix` file
under [`config/`](config/) is auto-imported as a flake-parts module (dirs
prefixed with `_` are excluded). Modules define feature sets under
`config.my.features.*`, hosts under `config.my.hosts`, and
[`config/outputs.nix`](config/outputs.nix) wires them into
`nixosConfigurations` / `darwinConfigurations` / `homeConfigurations`.

## Usage

### Rebuild NixOS Host

```bash
make nixos host=<hostname>
```

### Rebuild Darwin Host

```bash
make darwin host=<hostname>
```

### Rebuild Home Manager (standalone)

```bash
make home user=<username> host=<hostname>
```

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and stored in `secrets/`.

### Edit a secret

```bash
nix shell nixpkgs#sops nixpkgs#gnupg -c sops secrets/<file>.env
```
