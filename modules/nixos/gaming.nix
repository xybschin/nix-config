{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
    discord
    spotify
    wowup-cf
    protonup-rs

    # https://github.com/NixOS/nixpkgs/issues/513245#issuecomment-4319854191
    (pkgs.lutris.override {
      # Intercept buildFHSEnv to modify target packages
      buildFHSEnv =
        args:
        pkgs.buildFHSEnv (
          args
          // {
            multiPkgs =
              envPkgs:
              let
                # Fetch original package list
                originalPkgs = args.multiPkgs envPkgs;

                # Disable tests for openldap
                customLdap = envPkgs.openldap.overrideAttrs (_: {
                  doCheck = false;
                });
              in
              # Replace broken openldap with the custom one
              builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
          }
        );
    })
  ];

  programs = {
    steam = {
      enable = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
