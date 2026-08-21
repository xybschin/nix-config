{ ... }:
{
  config.my.features.home.global =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.stylix.homeModules.stylix
        ./_global/fzf.nix
        ./_global/zsh.nix
        ./_global/nvim.nix
        ./_global/herdr.nix
        ./_global/lazygit.nix
        ./_global/direnv.nix
        ./_global/ranger.nix
      ];

      # Safe default scheme so tmux/zsh color interpolation always resolves
      # (config.lib.stylix.colors is computed even when stylix.enable = false).
      # shared.stylix overrides this with the full theme on desktop hosts.
      stylix.base16Scheme =
        lib.mkDefault "${pkgs.base16-schemes}/share/themes/vesper.yaml";

      home.packages =
        with pkgs;
        [
          git
          tree
          unzip
          gnumake
          gh
          jq
          htop
          tldr
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.systemctl-tui
        ];

      home.stateVersion = "26.05";
    };
}
