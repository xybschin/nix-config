{
  config,
  configRoot,
  pkgs,
  lib,
  ...
}:
let
  quickshellDir = "${configRoot}/config/shared/_desktop/quickshell/config";
in
{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink quickshellDir;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "quickshell";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.quickshell;
      Restart = "always";
      RestartSec = "10";
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
