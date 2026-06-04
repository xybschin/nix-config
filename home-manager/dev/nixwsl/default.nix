{ pkgs, lib, ... }:
{
  # With systemd=true in wsl.conf, /run/user/1000 is still only created when
  # PAM establishes a login session, which WSL doesn't always do. Linger makes
  # systemd start the user session at boot, ensuring the dir always exists.
  home.activation.enableLinger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.systemd}/bin/loginctl enable-linger "$USER"
  '';
}
