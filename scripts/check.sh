#!/usr/bin/env bash
# Evaluate every flake configuration (nixos/darwin) and report failures.
set -u

: "${CONFIG_ROOT:=$(git rev-parse --show-toplevel)}"
export CONFIG_ROOT NIXPKGS_ALLOW_UNFREE=1

fail=0
checked=0
ok=0

check() {
  local kind=$1 attr=$2 names name out msg
  names=$(nix eval --impure --raw ".#$kind" \
    --apply 'c: builtins.concatStringsSep " " (builtins.attrNames c)') \
    || { echo "$kind.* FAIL could not list configurations"; fail=1; return; }
  for name in $names; do
    checked=$((checked + 1))
    if out=$(nix eval --impure --raw ".#$kind.\"$name\".$attr" 2>&1 >/dev/null); then
      ok=$((ok + 1))
      echo "$kind.$name ok"
    else
      msg=$(printf '%s\n' "$out" | grep -i error | tail -n 1)
      msg=${msg:-$(printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | tail -n 1)}
      msg=$(printf '%s' "$msg" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
      echo "$kind.$name FAIL: $msg"
      fail=1
    fi
  done
}

check nixosConfigurations config.system.build.toplevel.drvPath
check darwinConfigurations system.drvPath

echo "$checked checked, $ok ok, $((checked - ok)) failed"
exit $fail
