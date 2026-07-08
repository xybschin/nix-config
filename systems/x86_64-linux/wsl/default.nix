{
  pkgs,
  config,
  ...
}:

{
  snowfallorg.users.dev = {
    admin = true;
    home.enable = true;
  };

  home-manager.extraSpecialArgs.isWsl = true;

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
}
