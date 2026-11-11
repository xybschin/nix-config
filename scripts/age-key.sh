#!/usr/bin/env bash
# Fetch an age identity from the 1Password "sops-nix" vault and install it.
#
# usage: age-key.sh <name> [root]
#   name  identity = vault item name: moonz (user key), fenris, atlas (system keys)
#   root  optional install prefix, e.g. /mnt from the NixOS installer
#
# The key is the item's `password` field.
set -euo pipefail

if [[ -z ${1:-} ]]; then
    echo "usage: make age-key key=<moonz|fenris|atlas> [root=/mnt]" >&2
    exit 1
fi
item=$1
prefix=${2:-}

vault=${SOPS_VAULT:-sops-nix}
sops_yaml="$(git rev-parse --show-toplevel)/.sops.yaml"

case $item in
    moonz)
        dest=$prefix${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt
        as_root=()
        ;;
    atlas | fenris)
        [[ $item == atlas ]] && dest=/var/lib/sops-nix/age/keys.txt || dest=/var/lib/sops-nix/key.txt
        dest=$prefix$dest
        as_root=(sudo)
        [[ $EUID -eq 0 ]] && as_root=()
        ;;
    *)
        echo "unknown identity '$item' (expected moonz, fenris or atlas)" >&2
        exit 1
        ;;
esac

# op: use the installed CLI, else a throwaway nix shell (unfree).
if command -v op >/dev/null; then
    op=(op)
else
    export NIXPKGS_ALLOW_UNFREE=1
    op=(nix shell --impure nixpkgs#_1password-cli -c op)
fi

# `op item get` takes the title as an argument, so "/" in it is fine
# (it is not in an op:// reference).
key=$("${op[@]}" item get "$item" --vault "$vault" --fields password --reveal)
key=${key//\"/} # op may quote the value

if [[ $key != AGE-SECRET-KEY-1* ]]; then
    echo "item '$item' in vault '$vault' is not an age secret key" >&2
    exit 1
fi

# The public key must be a recipient in .sops.yaml, or the key is useless.
pub=$(age-keygen -y <<<"$key" 2>/dev/null || nix shell nixpkgs#age -c age-keygen -y <<<"$key")
if ! grep -q "$pub" "$sops_yaml"; then
    echo "public key $pub is not a recipient in .sops.yaml; not installing" >&2
    exit 1
fi

"${as_root[@]}" install -d -m 700 "$(dirname "$dest")"
printf '%s\n' "$key" | "${as_root[@]}" install -m 600 /dev/stdin "$dest"
echo "installed $item -> $dest ($pub)"
