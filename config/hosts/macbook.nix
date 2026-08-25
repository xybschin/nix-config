{ ... }:
{
  config.my.hosts.macbook = {
    system = "aarch64-darwin";
    username = "bjarne";
    isWsl = false;

    darwin.features = [
      "common"
    ];
    darwin.configuration = { pkgs, ... }: {
      system.primaryUser = "bjarne";
      system.stateVersion = 7;

      users.users.bjarne = {
        shell = pkgs.zsh;
        home = "/Users/bjarne";
        createHome = true;
      };

      homebrew.casks = [
        "zen-browser"
      ];
    };

    home.features = [
      "global"
      "git-identity"
      "1password"
      "coding-agents"
      "terminals"
    ];
    home.configuration = { pkgs, ... }: {
      home.packages = with pkgs; [
        obsidian
        python3
        nodejs
      ];
    };
  };
}
