{ lib, pkgs }:
# Machine-local overlay for coding agents: customer-specific settings that
# live outside this repo, in ~/.config/coding-agents/local/ (never written by
# Nix). `wrap` makes an agent honour that directory on every launch, so
# dropping or removing a file takes effect without a rebuild or a new shell.
#
#   env                 sourced before launch (secrets, referenced as {env:X})
#   claude/settings.json
#   copilot/{mcp-config,lsp-config,providers}.json
#   opencode/opencode.json
#
# `wrap` can also export variables from secret files (e.g. sops-nix paths);
# a variable already set by `env` or the caller wins.
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
      # Variable name -> path of a file holding its value.
      secretEnv ? { },
    }:
    let
      exportSecrets = lib.concatStrings (
        lib.mapAttrsToList (var: path: ''
          if [ -z "''${${var}-}" ] && [ -r "${path}" ]; then
            ${var}="$(<"${path}")"
            export ${var}
          fi
        '') secretEnv
      );
      launcher = pkgs.writeShellScript "${bin}-local-overlay" ''
        if [ -f "${dir}/env" ]; then
          set -a
          . "${dir}/env"
          set +a
        fi
        ${exportSecrets}
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
