{
  inputs,
  ...
}:
{
  config.my.hosts.nixwsl = {
    system = "x86_64-linux";
    username = "dev";
    isWsl = true;

    nixos.features = [
      "common"
    ];
    nixos.extraModules = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.vscode-server.nixosModules.default
    ];
    nixos.configuration = { pkgs, ... }: {
      networking.hostName = "nixwsl";

      users.users.dev = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
        ];
        shell = pkgs.zsh;
        hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
        linger = true;
      };

      services.vscode-server.enable = true;

      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = "dev";
        # interop.register stays false: WSL2 already registers WSLInterop itself
        # and makes /proc/sys/fs/binfmt_misc read-only, so re-registering makes
        # systemd-binfmt.service fail on every switch.
      };

      services.logind.enable = true;
      security.sudo.wheelNeedsPassword = false;
      virtualisation.docker = {
        enable = true;
      };
    };

    home.features = [
      "global"
      "1password"
      "coding-agents"
      "devenv"
      "workmux"
      "dotnet"
    ];
    home.configuration = { pkgs, ... }: {
      # Enables CLI theming (opencode, zsh, fzf, lazygit, ...) with koda-dark
      stylix = {
        enable = true;
        autoEnable = false;
        targets = {
          fzf.enable = true;
          lazygit.enable = true;
        };
      };

      home.packages = with pkgs; [
        ducker
        htop
        python3
        nodejs
        bun
        _1password-cli
        (pkgs.writeShellScriptBin "code" "exec code.exe --remote \"wsl+\${WSL_DISTRO_NAME}\" \"$@\"")
      ];

      home.sessionPath = [ "$HOME/.bun/bin" ];

      home.sessionVariables = {
        NODE_USE_SYSTEM_CA = "1";
      };
    };
  };
}
