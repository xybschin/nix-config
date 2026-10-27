{ ... }:
{
  # AirPods manager. The nixpkgs module installs the app and a cap_net_admin
  # setcap wrapper — BlueZ L2CAP needs CAP_NET_ADMIN to open the AirPods
  # control socket (otherwise battery/ANC control silently fails).
  config.my.features.nixos.librepods = { hostUser, ... }: {
    programs.librepods.enable = true;

    # The wrapper is group-executable; membership is what grants access.
    users.groups.librepods.members = [ hostUser ];
  };
}
