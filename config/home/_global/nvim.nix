{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  nvimDir = "${configRoot}/config/home/_global/nvim/config";
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    sideloadInitLua = true;
  };

  home.packages = with pkgs; [
    # LSP servers (must match `vim.lsp.enable()` in
    # config/home/_global/nvim/config/plugin/40_plugins.lua)
    bash-language-server
    cmake-language-server
    docker-language-server
    gopls
    lua-language-server
    nil
    omnisharp-roslyn
    tailwindcss-language-server
    typescript-language-server

    # Formatters (must match `formatters_by_ft` in the conform setup)
    beautysh
    go # gofmt
    gotools # goimports
    nixfmt
    prettier
    stylua
    yamlfmt

    # Tree-sitter parsers need the CLI and a C compiler to build
    gcc
    tree-sitter
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimDir;
}
