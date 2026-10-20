{ ... }:
{
  config.my.features.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      console.keyMap = "us";
      networking.networkmanager.enable = true;

      security.polkit.enable = true;

      zramSwap.enable = true;

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      environment.systemPackages = with pkgs; [
        gparted
        gnumake
        wl-clipboard
      ];

      programs.dconf.enable = true;

      boot.consoleLogLevel = 0;
    };
}
