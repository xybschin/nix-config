{ ... }:
{
  config.my.features.nixos.gnome-keyring = { pkgs, ... }: {
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [ seahorse ];
  };
}
