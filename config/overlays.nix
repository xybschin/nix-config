{ inputs, ... }:
let
  overlays = [
    (import ./_overlays/armada-theme.nix)
    (import ./_overlays/segoe-ui.nix)
    (import ./_overlays/xembsni.nix)
  ];
in
{
  flake.overlays.default = inputs.nixpkgs.lib.composeManyExtensions overlays;
}
