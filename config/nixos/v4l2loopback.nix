{ ... }:
{
  config.my.features.nixos.v4l2loopback =
    { config, lib, ... }:
    let
      cfg = config.my.v4l2loopback;
    in
    {
      options.my.v4l2loopback.videoNr = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 10;
        description = "Number N of the /dev/videoN device the fake camera writes to.";
      };

      config = {
        boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
        boot.kernelModules = [ "v4l2loopback" ];
        boot.extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=${toString cfg.videoNr} card_label="Virtual Webcam" exclusive_caps=1
        '';
      };
    };
}
