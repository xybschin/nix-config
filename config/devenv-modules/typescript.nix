{ ... }:
{
  # Shared typescript stack for per-project devenv shells. Import from a
  # project's devenv.nix via `imports = [ inputs.nix-config.devenvModules.typescript ];`
  config.my.devenvModules.typescript =
    { pkgs, ... }:
    {
      # languages.typescript installs node + typescript-language-server (LSP
      # is on by default).
      languages.typescript.enable = true;
      packages = [ pkgs.bun ];
    };
}
