{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "amd_pstate=active" ];

  snowfallorg.users.bjarne = {
    admin = true;
    home.enable = true;
  };

  users.users.bjarne = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "openrazer"
      "kvm"
      "libvirtd"
      "video"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NUUdJqm0TLbeSko6tfPww1$RQXYJ.jM17uWDkwmtlssASXcthw4MUo2Y9t.ixw63F9";
  };

  my.common-desktop.enable = true;
  my."1password".enable = true;
  my.boot.enable = true;
  my.virtualisation.enable = true;
  my.nvidia.enable = true;
  my.desktop.enable = true;
  my.audio.enable = true;
  my.bluetooth.enable = true;
  my.razer.enable = true;
  my.razer.dpi = 1000;
  my.gaming.enable = true;
  my.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-workspace
    gnupg
  ];
}
