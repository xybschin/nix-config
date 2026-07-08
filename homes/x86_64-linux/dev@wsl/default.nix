{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/home/coding-agents
  ];

  home.packages = with pkgs; [
    devenv
    ducker
    htop
    python3
    nodejs
    bun
  ];

  home.sessionPath = [ "$HOME/.bun/bin" ];

  home.sessionVariables = {
    NODE_USE_SYSTEM_CA = "1";
  };
}
