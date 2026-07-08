{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.my.gnome-keyring.enable = lib.mkEnableOption "GNOME Keyring";

  config = lib.mkIf config.my.gnome-keyring.enable {
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [ seahorse ];
  };
}
