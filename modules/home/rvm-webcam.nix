{ pkgs, inputs, ... }:
let
  rvmModel = pkgs.fetchurl {
    url = "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_resnet50.pth";
    hash = "sha256-wZGoByURZMBz3OX6QI56gWBw1Tm4grKjFQMwqf7BEs4=";
    name = "rvm_resnet50.pth";
  };
in
{
  imports = [ inputs.rvm-webcam.homeManagerModules.default ];
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
}
