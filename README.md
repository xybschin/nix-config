# NixOS Configuration

Flake-based NixOS, Darwin, and Home Manager configuration using [Snowfall Lib](https://snowfall.org).

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
