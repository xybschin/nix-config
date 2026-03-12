{ pkgs, ... }:

{
  environment.localBinInPath = true;
  programs.zsh.enable = true;
  users.users.bjarne = {
    isNormalUser = true;
    home = "/home/bjarne";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };

  programs.hyprland.enable = true;
}
