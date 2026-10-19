{ ... }:
{
  config.my.features.nixos.server =
    { pkgs, ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
          AllowUsers = [
            "moonz"
            "root"
          ];
        };
      };

      networking.firewall.allowedTCPPorts = [ 22 ];

      environment.systemPackages = with pkgs; [
        vim
        git
        dnsutils
        wireguard-tools
      ];
    };
}
