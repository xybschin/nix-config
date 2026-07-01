{ config, pkgs, inputs, ... }:
let
  rvmPkg = inputs.rvm-webcam.packages.${pkgs.stdenv.hostPlatform.system}.default;
  rvmModel = pkgs.fetchurl {
    url = "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_resnet50.pth";
    hash = "sha256-wZGoByURZMBz3OX6QI56gWBw1Tm4grKjFQMwqf7BEs4=";
    name = "rvm_resnet50.pth";
  };
in
{
  home.packages = [ rvmPkg ];

  systemd.user.services.rvm-webcam = {
    Unit = {
      Description = "rvm-webcam background removal virtual camera";
      After = "graphical-session.target";
      Wants = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${rvmPkg}/bin/rvm-webcam --on-demand";
      Restart = "on-failure";
      RestartSec = "3";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  xdg.configFile."rvm-webcam/config.json".text = builtins.toJSON {
    model_path = "${rvmModel}";
    backbone = "resnet50";
    bg_image = "/home/bjarne/wallpapers/single/artemis-ii-earth-peek.jpg";
    downsample_ratio = 0.25;
    precision = "auto";
    on_demand = true;
    compile = true;
  };
}
