#!/usr/bin/env bash
# Fetch an age identity from the 1Password "sops-nix" vault and install it.
# The item is a Document whose `keys.txt` file holds the age key; any item
# name works, the destination depends only on whether it is a user or root key.
#
# usage: age-key.sh <item> <user|root> [--prefix DIR] [--dest FILE]
#   item      1Password item name (vault: $SOPS_VAULT, default "sops-nix")
#   user      install to ~/.config/sops/age/keys.txt
#   root      install to /var/lib/sops-nix/key.txt, via sudo
#   --prefix  prepend to the destination, e.g. /mnt from the NixOS installer
#   --dest    destination override, e.g. /var/lib/sops-nix/age/keys.txt
set -euo pipefail

usage() {
    echo "usage: age-key.sh <item> <user|root> [--prefix DIR] [--dest FILE]" >&2
    exit "${1:-1}"
}

if (($# < 2)); then
    usage
fi
item=$1
kind=$2
shift 2

prefix=
dest=
while (($#)); do
    case $1 in
        --prefix) prefix=${2:?--prefix needs a value}; shift 2 ;;
        --prefix=*) prefix=${1#*=}; shift ;;
        --dest) dest=${2:?--dest needs a value}; shift 2 ;;
        --dest=*) dest=${1#*=}; shift ;;
        -h | --help) usage 0 ;;
        *) echo "unknown argument '$1'" >&2; usage ;;
    esac
done

case $kind in
    user | root) ;;
    *) echo "unknown kind '$kind'" >&2; usage ;;
esac

vault=${SOPS_VAULT:-sops-nix}
sops_yaml="$(git rev-parse --show-toplevel)/.sops.yaml"

# Standard sops locations: the CLI/Home Manager default for user keys, and the
# sops-nix default for system keys. Hosts that configure another path pass
# --dest rather than teaching this script about individual hosts.
if [[ -z $dest ]]; then
    if [[ $kind == user ]]; then
        dest=${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt
    else
        dest=/var/lib/sops-nix/key.txt
    fi
fi
dest=$prefix$dest

as_root=()
if [[ $kind == root ]]; then
    [[ $EUID -eq 0 ]] || as_root=(sudo)
fi

# op: use the installed CLI, else a throwaway nix shell (unfree).
if command -v op >/dev/null; then
    op=(op)
else
    export NIXPKGS_ALLOW_UNFREE=1
    op=(nix shell --impure nixpkgs#_1password-cli -c op)
fi

# Document items expose the uploaded file as a field named after it (`keys.txt`),
# so read it through an op:// secret reference rather than `op item get`.
# Item names are part of that reference, so avoid "/" in them.
if ! key=$("${op[@]}" read "op://$vault/$item/keys.txt"); then
    echo "could not read keys.txt from item '$item' in vault '$vault'" >&2
    exit 1
fi
key=${key//\"/} # op may quote the value
# The document may be a whole age key file; keep only the secret key line.
key=$(grep -m1 '^AGE-SECRET-KEY-1' <<<"$key" || true)

if [[ -z $key ]]; then
    echo "item '$item' in vault '$vault' has no AGE-SECRET-KEY-1 line in keys.txt" >&2
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
