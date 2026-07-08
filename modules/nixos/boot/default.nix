{
  config,
  lib,
  ...
}:

{
  options.my.boot.enable = lib.mkEnableOption "Boot configuration";

  config = lib.mkIf config.my.boot.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
          consoleMode = "max";
        };
      };
    };
  };
}
