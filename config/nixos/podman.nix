{ ... }:
{
  # Rootful podman as the OCI backend. Rootful (not rootless) because the
  # services live on a host-visible bridge with static IPs that the host
  # firewall and WireGuard clients route to directly; rootless networking
  # lives in a separate netns and cannot do that.
  #
  # Container IP plan on `infra` (br-infra, 10.0.2.0/24, gateway 10.0.2.1):
  #   10.0.2.2  pihole
  #   10.0.2.3  traefik
  config.my.features.nixos.podman =
    { pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        # No docker-compat socket: it would be a root-equivalent API.
        dockerSocket.enable = false;
        # The default bridge is unused; only `infra` is used.
        defaultNetwork.settings.dns_enabled = false;
      };
      virtualisation.oci-containers.backend = "podman";

      # Pull newer images for containers labelled
      # io.containers.autoupdate=registry and restart their systemd units.
      systemd.timers.podman-auto-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # Weekly, Monday 03:00 (host timezone). Replaces the package's daily default.
          OnCalendar = [
            ""
            "Mon *-*-* 03:00:00"
          ];
          RandomizedDelaySec = 0;
          Persistent = true;
        };
      };

      # Required for netavark's nftables driver (the podman module switches
      # firewall_driver automatically) and for filtering forwarded traffic.
      networking.nftables.enable = true;
      networking.firewall.filterForward = true;
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      # Container egress. Netavark masquerades 10.0.2.0/24 itself, so no
      # manual NAT rule is needed. Per-service ingress rules (wg0 ->
      # containers) live in the respective service feature.
      networking.firewall.extraForwardRules = ''
        iifname "br-infra" oifname "eth0" accept
        iifname "br-infra" oifname "br-infra" accept
      '';

      # Equivalent of the compose `networks:` block on the old VPS.
      systemd.services.podman-network-infra = {
        description = "Create the podman `infra` network (br-infra)";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman network exists infra || podman network create \
            --driver bridge \
            --subnet 10.0.2.0/24 \
            --gateway 10.0.2.1 \
            --interface-name br-infra \
            --disable-dns \
            infra
        '';
      };
    };
}
