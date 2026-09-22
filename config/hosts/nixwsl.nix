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
        interop.register = true;
      };

      services.logind.enable = true;
      virtualisation.docker.enable = true;
      security.sudo.wheelNeedsPassword = false;

      environment.systemPackages = with pkgs; [
        (azure-cli.withExtensions [ azure-cli.extensions.azure-devops ])
      ];
    };

    home.features = [
      "global"
      "1password"
      "coding-agents"
    ];
    home.configuration = { pkgs, inputs, ... }: {
      # Enables CLI theming (opencode, zsh, fzf, lazygit, ...) with koda-dark
      stylix = {
        enable = true;
        autoEnable = false;
        targets = {
          fzf.enable = true;
          lazygit.enable = true;
        };
      };

      home.packages =
        with pkgs;
        [
          home-manager
          devenv
          ducker
          htop
          python3
          nodejs
          bun
          (pkgs.writeShellScriptBin "code" "exec code.exe --remote \"wsl+\${WSL_DISTRO_NAME}\" \"$@\"")

          # bd/beads issue tracker for AI-supervised coding workflows. Taken
          # from the flake's own package set rather than its overlay: beads'
          # postPatch rewrites go.mod to the toolchain's Go version, which
          # breaks vendoring against our unstable Go. Upstream pins nixos-25.11.
          inputs.beads.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

      home.sessionPath = [ "$HOME/.bun/bin" ];

      home.sessionVariables = {
        NODE_USE_SYSTEM_CA = "1";
      };
    };
  };
}
