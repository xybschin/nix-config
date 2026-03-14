# NixOS Configuration

Flake-based NixOS and Home Manager configuration.

## Available Systems

- **nixvidia** - Main desktop (NVIDIA GPU)
- **nixvm** - Virtual machine
- **nixwsl** - WSL2 configuration

## Usage

### Rebuild NixOS Host

```bash
make build-host host=<hostname>
```

Example:
```bash
make build-host host=nixvidia
```

### Rebuild Home Manager

```bash
make build-user user=<username>
```

Example:
```bash
make build-user user=dev
```

## Corporate Proxy/Firewall SSL Configuration

If you are behind a corporate proxy or firewall, you may need to configure SSL certificates for Nix to work properly. Add the following to the nix-daemon environment.

### Option 1: Edit Host Configuration

Add to your host's `default.nix` file (e.g., `hosts/nixvidia/default.nix`):

```nix
{ pkgs, inputs, ... }:

{
  # ... existing config ...

  # For corporate proxy/firewall SSL certificates
  systemd.services.nix-daemon.environment = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
```

Replace `/etc/ssl/certs/ca-certificates.crt` with the path to your corporate CA certificate bundle if different.

### Option 2: Set Globally in Nix Config

Alternatively, add to `/etc/nix/nix.conf` on the target machine:

```
extra-nix-path = nix-config=/path/to/nix-config
trusted-public-keys = ...
```

Then add to `nix.settings`:

```nix
nix.settings = {
  # ...
  # For corporate proxy/firewall SSL certificates
  nix-daemon-environment = {
    NIX_SSL_CERT_FILE = "/path/to/cert.pem";
    SSL_CERT_FILE = "/path/to/cert.pem";
  };
};
```

After making changes, rebuild with:
```bash
make build-host host=<your-host>
```
