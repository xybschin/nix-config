{ inputs, ... }:
let
  overlays = [
    (import ./_overlays/segoe-ui.nix)
  ];
in
{
  flake.overlays.default = inputs.nixpkgs.lib.composeManyExtensions overlays;
}
