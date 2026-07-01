{ config, lib, pkgs, inputs, ... }:
let
  rvmPkg = inputs.rvm-webcam.packages.${pkgs.stdenv.hostPlatform.system}.default;

  modelHashes = {
    mobilenetv3 = "sha256-PHwdkgM/fDjWV3xIHROhldfYChWblg9PMRmse1NM9Pg=";
    resnet50 = "sha256-wZGoByURZMBz3OX6QI56gWBw1Tm4grKjFQMwqf7BEs4=";
  };

  modelUrl = backbone:
    "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_${backbone}.pth";

  fetchedModel = pkgs.fetchurl {
    url = modelUrl config.services.rvm-webcam.backbone;
    hash = modelHashes.${config.services.rvm-webcam.backbone};
    name = "rvm_${config.services.rvm-webcam.backbone}.pth";
  };

  resolvedModelPath =
    if config.services.rvm-webcam.modelPath != null
    then config.services.rvm-webcam.modelPath
    else "${fetchedModel}";
in {
  options.services.rvm-webcam = {
    enable = lib.mkEnableOption "rvm-webcam background removal virtual camera";
    modelPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to the RVM model .pth file. If null, auto-fetched based on backbone.";
    };
    backbone = lib.mkOption {
      type = lib.types.enum [ "mobilenetv3" "resnet50" ];
      default = "mobilenetv3";
    };
    width = lib.mkOption { type = lib.types.int; default = 1280; };
    height = lib.mkOption { type = lib.types.int; default = 720; };
    fps = lib.mkOption { type = lib.types.int; default = 30; };
    extraConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
    };
  };

  config = lib.mkIf config.services.rvm-webcam.enable {
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

    xdg.configFile."rvm-webcam/config.json".text = builtins.toJSON (
      {
        model_path = resolvedModelPath;
        backbone = config.services.rvm-webcam.backbone;
        width = config.services.rvm-webcam.width;
        height = config.services.rvm-webcam.height;
        fps = config.services.rvm-webcam.fps;
      } // config.services.rvm-webcam.extraConfig
    );
  };
}
