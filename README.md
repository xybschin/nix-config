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

### Via systemctl edit (non-NixOs hostst)

Edit the nix-daemon service to set environment variables:

```bash
sudo systemctl edit nix-daemon
```

Add the following in the editor:

```ini
[Service]
Environment="NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
Environment="SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
```

Then restart the daemon:

```bash
sudo systemctl restart nix-daemon
```
