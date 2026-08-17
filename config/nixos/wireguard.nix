{ ... }:
{
  config.my.features.nixos.wireguard =
    { pkgs, ... }:
    {
      networking.wireguard.enable = true;
      environment.systemPackages = [ pkgs.wireguard-tools ];
    };
}
