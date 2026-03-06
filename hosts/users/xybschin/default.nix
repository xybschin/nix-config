{ pkgs, user, ... }:

{
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    home = "/home/${user}";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };
}
