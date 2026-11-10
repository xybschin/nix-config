{ ... }:
{
  config.my.features.nixos.boot = { lib, ... }: {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 3;
          consoleMode = "max";
        };
        timeout = lib.mkDefault 15;
      };
    };
  };
}
