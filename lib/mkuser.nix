{
  pkgs,
  name,
  extraGroups ? [ ],
}:

{
  users.users.${name} = {
    isNormalUser = true;
    home = "/home/${name}";
    extraGroups = [
      "wheel"
      "docker"
    ]
    ++ extraGroups;
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };
}
