{
  config,
  configRoot,
  pkgs,
  inputs,
  ...
}:
let
  nvimDir = "${configRoot}/modules/home-manager/nvim/config";
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  programs.neovim = {
    enable = true;
    package = neovim-nightly;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    # LSP
    nil
    bash-language-server
    lua-language-server
    cmake-language-server
    docker-language-server

    # Formatter
    nixfmt
    prettier
    beautysh
    stylua
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimDir;
}
