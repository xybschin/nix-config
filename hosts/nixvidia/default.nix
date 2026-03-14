{
  pkgs,
  inputs,
  user,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  console.keyMap = "us";
  networking.hostName = "nixvidia";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol
    easyeffects
    vesktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [
        "root"
        user
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  system.stateVersion = "25.05";
}
