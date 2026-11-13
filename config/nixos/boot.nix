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

      # Graphical splash from initrd up to the greeter. The module adds the
      # `splash` param itself; `quiet` keeps systemd/udev text off the console
      # (`boot.consoleLogLevel` in the desktop feature already silences the
      # kernel). Theme is explicit so it does not depend on firmware BGRT.
      #
      # Scope: `plymouth-quit` is wired to multi-user.target, so the splash
      # ends right before graphical.target starts greetd. It cannot span the
      # tuigreet prompt or the handoff to Hyprland — after login the first
      # thing on screen is hyprpaper's wallpaper, by design.
      plymouth = {
        enable = true;
        theme = "spinner";
      };
      kernelParams = [ "quiet" ];
    };
  };
}
