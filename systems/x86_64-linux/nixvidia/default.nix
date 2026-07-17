{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [
    "amd_pstate=active"
    "pcie_aspm=off"
    "usbcore.autosuspend=-1"
  ];

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

  boot.extraModprobeConfig = "options hid_apple fnmode=2";

  boot.loader.timeout = 10;
  boot.loader.systemd-boot.extraEntries = {
    "bazzite.conf" = ''
      title Bazzite
      efi /EFI/fedora/grubx64.efi
      sort-key @bazzite
    '';
  };
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
    gnupg
    efibootmgr
  ];
}
