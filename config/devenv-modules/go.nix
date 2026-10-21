{ ... }:
{
  # Shared go stack for per-project devenv shells. Import from a project's
  # devenv.nix via `imports = [ inputs.nix-config.devenvModules.go ];`
  config.my.devenvModules.go =
    { pkgs, ... }:
    {
      # languages.go installs go + gopls (LSP is on by default).
      languages.go.enable = true;
      packages = with pkgs; [
        gotools
        golangci-lint
        delve
      ];
    };
}
