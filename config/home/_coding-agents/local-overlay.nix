{ lib, pkgs }:
# Machine-local overlay for coding agents: customer-specific settings that
# live outside this repo, in ~/.config/coding-agents/local/ (never written by
# Nix). `wrap` makes an agent honour that directory on every launch, so
# dropping or removing a file takes effect without a rebuild or a new shell.
#
#   env                 sourced before launch (secrets, referenced as {env:X})
#   <agent files>       see each agent's `prelude` in its module
let
  dir = "$HOME/.config/coding-agents/local";
in
{
  inherit dir;

  wrap =
    {
      package,
      bin,
      # Shell run after `env` is sourced and before the agent starts. May
      # export variables or `set --` extra arguments.
      prelude ? "",
    }:
    let
      launcher = pkgs.writeShellScript "${bin}-local-overlay" ''
        if [ -f "${dir}/env" ]; then
          set -a
          . "${dir}/env"
          set +a
        fi
        ${prelude}
        exec ${lib.getExe' package bin} "$@"
      '';
    in
    pkgs.symlinkJoin {
      name = "${package.name}-local-overlay";
      paths = [ package ];
      inherit (package) meta;
      postBuild = ''
        rm "$out/bin/${bin}"
        ln -s ${launcher} "$out/bin/${bin}"
      '';
    };
}
