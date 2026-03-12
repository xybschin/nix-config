{ pkgs, ... }:

{
  environment.localBinInPath = true;
  programs.zsh.enable = true;
  users.users.dev = {
    isNormalUser = true;
    home = "/home/dev";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };
}
