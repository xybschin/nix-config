{ ... }:
{
  config.my.features.nixos.logiops = { pkgs, ... }: {
    # logid gives up after 5 tries when the hidraw node appears (bluez >= 5.77
    # regression + UHID/hidraw race, see logiops #468/#522) and never retries.
    # Restart it whenever a Logitech hidraw device shows up so it re-attaches.
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="hidraw", KERNELS=="0005:046D:*", RUN+="/run/current-system/systemd/bin/systemctl restart --no-block logid.service"
      ACTION=="add|change", SUBSYSTEM=="hidraw", SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", RUN+="/run/current-system/systemd/bin/systemctl restart --no-block logid.service"
    '';
    services.logiops = {
      enable = true;
      config = {
        devices = [
          {
            name = "MX Master 3S";
            dpi = 600;
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
