# overlays/vscode-beads.nix
# Not packaged in nixpkgs; fetched from the VS Code Marketplace.
final: prev: {
  vscode-extensions = prev.vscode-extensions // {
    planet57 = (prev.vscode-extensions.planet57 or { }) // {
      vscode-beads = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-beads";
          publisher = "planet57";
          version = "0.15.0";
          sha256 = "sha256-/pwAT5YarlIr9993kJThq8vNtelBYJtWHhTwrF/PXic=";
        };
      };
    };
  };
}
