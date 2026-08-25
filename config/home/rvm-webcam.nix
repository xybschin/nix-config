{ ... }:
{
  config.my.features.home.rvm-webcam =
    {
      config,
      inputs,
      ...
    }:
    {
      imports = [ inputs.rvm-webcam.homeManagerModules.default ];

      services.rvm-webcam = {
        enable = true;
        modelPath = "${config.home.homeDirectory}/.local/share/rvm-webcam/rvm_resnet50_fp16.onnx";
        cacheDir = "${config.xdg.cacheHome}/rvm-webcam/migraphx";
        extraConfig = {
          bg_image = "${config.home.homeDirectory}/webcam-backgrounds/pub.png";
        };
      };
    };
}
