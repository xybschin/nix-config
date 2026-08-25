{ ... }:
{
  config.my.features.nixos.boot = { lib, ... }: {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 1;
          consoleMode = "max";
        };
        timeout = lib.mkDefault 5;
      };
    };
  };
}
