# NixOS Configuration

Flake-based NixOS and Home Manager configuration.

## Usage

### Rebuild NixOS Host

```bash
make build-host host=<hostname>
```

### Rebuild Home Manager

```bash
make build-user user=<username>
```

## Corporate Proxy/Firewall SSL Configuration

If you are behind a corporate proxy or firewall, you may need to configure SSL certificates for Nix to work properly.

### Home-Manager Only (Non-NixOS)

For hosts running home-manager without NixOS, add the following to your user's home-manager configuration (e.g., `home-manager/dev/default.nix`):

```nix
{ pkgs, inputs, ... }:

{
  # For corporate proxy/firewall SSL certificates
  home.sessionVariables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
```

### /etc/nix/nix.conf

Alternatively, add directly to `/etc/nix/nix.conf` on the target machine:

```
NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
```

Replace `/etc/ssl/certs/ca-certificates.crt` with the path to your corporate CA certificate bundle if different.

After making changes, rebuild with:
```bash
make build-user user=<your-user>
```
