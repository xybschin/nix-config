# Brave, while nixos-unstable catches up with the re-add.
#
# nixpkgs dropped brave and brave-origin on 2026-11-03 (no committer left to
# handle security updates) and re-added them in NixOS/nixpkgs#584534, merged
# into master on 2026-11-07 15:36 UTC. `nixos-unstable` is still parked on the
# 2026-11-07 09:04 commit, i.e. before the re-add, so `pkgs.brave` still
# throws here even though upstream is fixed.
#
# Until the channel moves, build the package from the maintainer's stopgap
# flake: nixpkgs' own expression (wrapper flags, desktop files, VA-API
# support unchanged) pointed at current upstream releases. Because the input
# sets `inputs.nixpkgs.follows = "nixpkgs"`, it is built by our own nixpkgs
# exactly as if the package had never been removed — no second nixpkgs eval.
#
# Delete this file, its entry in ../overlays.nix and the input in flake.nix
# once `nix eval --raw github:NixOS/nixpkgs/nixos-unstable#brave.version`
# stops erroring.
{ inputs }:
final: prev:
{
  inherit (prev.callPackage "${inputs.brave-browser-nix}/brave" { }) brave brave-origin;
}
