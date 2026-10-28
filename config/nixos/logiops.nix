{ ... }:
{
  config.my.features.nixos.logiops = { pkgs, ... }: {
    services.logiops = {
      enable = true;
      config = {
        devices = [
          {
            name = "MX Master 3S";
            dpi = 700;
            smartshift = {
              on = false;
              threshold = 30; # Optional, but helps ensure the block is fully parsed
            };
            hiresscroll = {
              hires = false;
              invert = false;
              target = false;
            };
          }
        ];
      };
    };
  };
}
