#!/usr/bin/env bash
# Add a WireGuard client to atlas.
#
# Generates a keypair and preshared key, stores the PSK in sops, registers the
# peer in the registry file and writes a ready-to-import client config. The
# client's private key never touches the repo. The address plan (endpoint,
# DNS, routes, subnet, file paths) and the address allocation come from the
# wireguard-server feature via `nix eval`; nothing is hardcoded here.
#
#   scripts/wg-add-peer.sh <name> [--address 10.0.3.X] [--home-lan]
#                          [--lan CIDR]... [--out DIR] [--deploy] [--commit]
#
#   --address   tunnel address; default: next free one in the tunnel subnet
#   --home-lan  also route the home LAN through the tunnel
#   --lan CIDR  LAN behind this peer that atlas should route to it (e.g. a
#               site-to-site router). Do NOT add it to that router's own
#               AllowedIPs.
#   --out DIR   where the client config is written (default: ~/Downloads)
#   --deploy    run `make nixos-remote host=atlas target=atlas` afterwards
#   --commit    commit wg-peers.json and secrets/atlas.yaml (only those two)
#               as "feat(atlas): add wireguard peer <name>"; with --deploy,
#               only after the deploy succeeded
set -euo pipefail

# Re-exec inside a nix shell when tools are missing.
missing=0
for tool in wg sops jq qrencode; do command -v "$tool" >/dev/null || missing=1; done
if [[ -z ${WG_ADD_PEER_IN_NIX:-} ]] && ((missing)); then
    exec env WG_ADD_PEER_IN_NIX=1 nix shell \
        nixpkgs#wireguard-tools nixpkgs#sops nixpkgs#jq nixpkgs#qrencode \
        -c "$0" "$@"
fi

usage() { sed -n '2,/^set /p' "$0" | sed '$d; s/^# \{0,1\}//' >&2; exit 1; }

root=$(git rev-parse --show-toplevel)
export SOPS_AGE_KEY_FILE=${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/atlas.txt}

name=${1:-}
[[ -n $name && $name != -* ]] || usage
shift
# Also guards the Nix expression below; the feature enforces the same rule.
[[ $name =~ ^[a-z0-9][a-z0-9_-]*$ ]] || {
    echo "invalid name '$name' (use a-z, 0-9, _ and -)" >&2
    exit 1
}

address=
home_lan=0
lans=()
out_dir=$HOME/Downloads
deploy=0
commit=0
while (($#)); do
    case $1 in
    --address) address=${2:?}; shift 2 ;;
    --home-lan) home_lan=1; shift ;;
    --lan) lans+=("${2:?}"); shift 2 ;;
    --out) out_dir=${2:?}; shift 2 ;;
    --deploy) deploy=1; shift ;;
    --commit) commit=1; shift ;;
    *) usage ;;
    esac
done

if [[ -n $address ]]; then
    [[ $address =~ ^[0-9.]+$ ]] || { echo "invalid address '$address'" >&2; exit 1; }
    address_expr=\"$address\"
else
    address_expr=null
fi

# One evaluation: the address plan, plus the feature's allocation (which also
# rejects duplicate names and addresses).
if ! plan=$(CONFIG_ROOT=$root NIXPKGS_ALLOW_UNFREE=1 nix eval --impure --json \
    "$root#nixosConfigurations.atlas.config.my.wireguard.server" \
    --apply "w: { info = w.clientInfo; address = w.allocate { name = \"$name\"; address = $address_expr; }; }" \
    2>/tmp/wg-add-peer.err); then
    grep -i 'error' /tmp/wg-add-peer.err | tail -n 1 >&2 || cat /tmp/wg-add-peer.err >&2
    exit 1
fi
address=$(jq -r '.address' <<<"$plan")
info() { jq -r "$1" <<<"$plan"; }

peers_file=$root/$(info .info.peersFile)
secrets_file=$root/$(info .info.secretsFile)
psk_key=$(info .info.pskPrefix)$name
SERVER_ENDPOINT=${WG_SERVER_ENDPOINT:-$(info .info.endpoint)}
SERVER_DNS=$(info .info.dns)
HOME_LAN=$(info .info.homeLan)
PREFIX_LENGTH=$(info .info.prefixLength)
mapfile -t TUNNEL_ROUTES < <(info '.info.routes[]')

[[ -f $peers_file ]] || { echo "missing $peers_file" >&2; exit 1; }
[[ -f $SOPS_AGE_KEY_FILE ]] || { echo "missing age key: $SOPS_AGE_KEY_FILE" >&2; exit 1; }

# Server public key, derived from the private key in sops.
server_pub=$(sops -d --extract '["wireguard_private_key"]' "$secrets_file" | wg pubkey)

priv=$(wg genkey)
pub=$(wg pubkey <<<"$priv")
psk=$(wg genpsk)

# Store the PSK (sops-nix decrypts it on atlas), then register the peer.
sops set "$secrets_file" "[\"$psk_key\"]" "\"$psk\""

lan_json=$(printf '%s\n' "${lans[@]:-}" | jq -R . | jq -s 'map(select(. != ""))')
tmp=$(mktemp)
jq --arg n "$name" --arg a "$address" --arg k "$pub" --argjson lan "$lan_json" \
    '. + [{name: $n, address: $a, publicKey: $k} + (if ($lan | length) > 0 then {lan: $lan} else {} end)]' \
    "$peers_file" >"$tmp"
mv "$tmp" "$peers_file"
git -C "$root" add "$peers_file" "$secrets_file"

# Client config.
allowed=("${TUNNEL_ROUTES[@]}")
((home_lan)) && allowed+=("$HOME_LAN")
allowed_str=$(IFS=,; echo "${allowed[*]}" | sed 's/,/, /g')

mkdir -p "$out_dir"
conf=$out_dir/wg-$name.conf
(
    umask 077
    cat >"$conf" <<EOF
[Interface]
PrivateKey = $priv
Address = $address/$PREFIX_LENGTH
DNS = $SERVER_DNS

[Peer]
PublicKey = $server_pub
PresharedKey = $psk
AllowedIPs = $allowed_str
PersistentKeepalive = 25
Endpoint = $SERVER_ENDPOINT
EOF
)

echo "peer '$name' added: $address ($pub)"
echo "client config: $conf"
if command -v qrencode >/dev/null; then
    echo "QR code (phones):"
    qrencode -t ansiutf8 <"$conf"
fi

if ((deploy)); then
    make -C "$root" nixos-remote host=atlas target=atlas
fi

if ((commit)); then
    git -C "$root" commit -q -m "feat(atlas): add wireguard peer $name" \
        -- "$peers_file" "$secrets_file"
    echo "committed: $(git -C "$root" log --oneline -1)"
else
    echo
    ((deploy)) || echo "Not deployed yet. Run: make nixos-remote host=atlas target=atlas"
    echo "Commit wg-peers.json and secrets/atlas.yaml when done."
fi
