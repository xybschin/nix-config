#!/usr/bin/env bash
# Install NixOS on a remote host, seeding the sops age key via nixos-anywhere.
set -euo pipefail

if [[ -z ${1:-} || -z ${2:-} ]]; then
    echo "usage: make nixos-install host=<name> target=<address>" >&2
    exit 1
fi
host=$1
target=$2

age_key=$HOME/.config/sops/age/atlas.txt
extra=/tmp/atlas-extra

if [[ ! -f $age_key ]]; then
    echo "missing age key: ~/.config/sops/age/atlas.txt" >&2
    exit 1
fi

cleanup() { rm -rf "$extra"; }
trap cleanup EXIT

mkdir -p "$extra/var/lib/sops-nix/age"
cp "$age_key" "$extra/var/lib/sops-nix/age/keys.txt"
chmod 600 "$extra/var/lib/sops-nix/age/keys.txt"

nix run github:nix-community/nixos-anywhere -- \
    --flake ".#$host" --extra-files "$extra" "root@$target"
