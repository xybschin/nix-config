{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  snowfallorg.users.dev = {
    admin = true;
    home.enable = true;
  };

  users.users.dev = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };

  my.common-desktop.enable = true;
  my."1password".enable = true;
  my.boot.enable = true;
  my.desktop.enable = true;
  my.audio.enable = true;
  my.bluetooth.enable = true;
}
