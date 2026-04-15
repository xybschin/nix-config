{ pkgs }:

let
  common = import ./common { inherit pkgs; };
in
common