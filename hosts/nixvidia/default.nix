{
  pkgs,
  inputs,
  ...
}:
let
  rvmModel = pkgs.fetchurl {
    url = "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_resnet50.pth";
    hash = "sha256-wZGoByURZMBz3OX6QI56gWBw1Tm4grKjFQMwqf7BEs4=";
    name = "rvm_resnet50.pth";
  };
in {
  boot.kernelParams = [ "amd_pstate=active" ];

  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/common-desktop.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/razer.nix
    ../../modules/nixos/gaming.nix
    inputs.rvm-webcam.nixosModules.default
  ];

  services.rvm-webcam = {
    enable = true;
    modelPath = "${rvmModel}";
    backbone = "resnet50";
    extraConfig = {
      bg_image = "/home/bjarne/wallpapers/single/artemis-ii-earth-peek.jpg";
      downsample_ratio = 0.25;
      precision = "auto";
      on_demand = true;
      compile = true;
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-workspace
  ];
}
