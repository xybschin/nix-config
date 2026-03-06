{
  pkgs,
  config,
  configRoot,
  ...
}:
let
  nvimDir = "${configRoot}/modules/home-manager/cli/nvim/config";
in
{
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    neovim

    # LSP
    nil
    bash-language-server
    lua-language-server
    cmake-language-server
    docker-language-server

    # Formtter
    nixfmt
    prettierd
    beautysh
    stylua
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimDir;
}
