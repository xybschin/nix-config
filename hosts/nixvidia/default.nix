{ ... }:

{
  imports = [
    ./hardware/desktop-nvidia.nix
    ../modules/nixos/boot.nix
    ../modules/nixos/nvidia.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/greetd.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/bluetooth.nix
  ];

  system.stateVersion = "25.05";
}
