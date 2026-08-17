{ ... }:
{
  config.my.features.nixos.logiops = { pkgs, ... }: {
    services.logiops = {
      enable = true;
      config = {
        devices = [
          {
            name = "MX Master 3S";
            dpi = 400;
            smartshift = {
              on = false;
              threshold = 255;
            };
            hiresscroll = {
              hires = true;
              invert = false;
              target = false;
            };
          }
        ];
      };
    };
  };
}
