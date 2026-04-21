{
  config,
  configRoot,
  pkgs,
  ...
}:
let
  nvimDir = "${configRoot}/modules/home-manager/nvim/config";
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
