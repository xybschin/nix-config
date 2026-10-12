{ ... }:
{
  config.my.features.home.xembsni =
    {
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.xembsni ];

      systemd.user.services.xembsni = {
        Unit = {
          Description = "XEmbed to StatusNotifierItem tray bridge";
          Documentation = [ "https://github.com/jmylchreest/xembsni" ];
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = lib.getExe pkgs.xembsni;
          Restart = "on-failure";
          RestartSec = 2;
          Environment = [ "RUST_LOG=info" ];
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
