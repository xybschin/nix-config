{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      autoupdate = false;
      lsp.nil = {
        command = [ "nil" ];
        extensions = [ ".nix" ];
        settings.nil.formatting.command = [ "nixfmt" ];
      };
    };
  };

  home.shellAliases.oc = "opencode";
}
