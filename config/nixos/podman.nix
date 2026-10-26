{ ... }:
{
  # Rootful podman as the OCI backend. Rootful (not rootless) because the
  # services live on a host-visible bridge with static IPs that the host
  # firewall and WireGuard clients route to directly; rootless networking
  # lives in a separate netns and cannot do that. The bridge itself and the
  # container IP plan live in the `infra-network` feature.
  config.my.features.nixos.podman =
    { ... }:
    {
      virtualisation.podman = {
        enable = true;
        # No docker-compat socket: it would be a root-equivalent API.
        dockerSocket.enable = false;
        # The default bridge is unused; only the infra network is used.
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
    };
}
