# Not packaged in nixpkgs; fetched from the VS Code Marketplace.
final: prev: {
  vscode-extensions = prev.vscode-extensions // {
    davidseptimus = (prev.vscode-extensions.davidseptimus or { }) // {
      armada-theme = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "armada-theme";
          publisher = "davidseptimus";
          version = "1.0.1";
          sha256 = "sha256-lNB+e+i37Z99F8GNBj1pJ8GcXLvznfV/jdpveH7tUfA=";
        };
      };
    };
  };
}
