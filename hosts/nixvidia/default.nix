{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/common-desktop.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/razer.nix
    ../../modules/nixos/gaming.nix
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-workspace
  ];
}
