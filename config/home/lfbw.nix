{ ... }:
{
  config.my.features.home.lfbw =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      cfg = config.services.lfbw;
      format = pkgs.formats.keyValue { };
    in
    {
      options.services.lfbw = {
        enable = lib.mkEnableOption "Linux Fake Background Webcam as a user service";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.lfbw;
          defaultText = lib.literalExpression "pkgs.lfbw";
          description = "The lfbw package to run.";
        };

        settings = lib.mkOption {
          type = lib.types.submodule {
            freeformType = format.type;
            options = {
              width = lib.mkOption {
                type = lib.types.int;
                default = 1280;
                description = "Capture and output width.";
              };
              height = lib.mkOption {
                type = lib.types.int;
                default = 720;
                description = "Capture and output height.";
              };
              fps = lib.mkOption {
                type = lib.types.int;
                default = 30;
                description = "Frame rate.";
              };
              webcam-path = lib.mkOption {
                type = lib.types.str;
                default = "/dev/video0";
                description = "Physical camera device.";
              };
              v4l2loopback-path = lib.mkOption {
                type = lib.types.str;
                default = "/dev/video${toString osConfig.my.v4l2loopback.videoNr}";
                description = "v4l2loopback device the fake camera writes to.";
              };
              background = lib.mkOption {
                type = lib.types.str;
                default = "no";
                description = "Background filter spec (see `lfbw --help`). Unset by default.";
              };
              mask = lib.mkOption {
                type = lib.types.str;
                default = "no";
                description = "Foreground mask spec (see `lfbw --help`). Unset by default.";
              };
            };
          };
          default = { };
          description = ''
            Options written to lfbw's config file, one per long option name
            (see `lfbw --help`). Any key not listed above is passed through
            as-is, e.g. `background = "file=/path/to/image.jpg";`.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        xdg.configFile."lfbw/lfbw.ini".source = format.generate "lfbw.ini" cfg.settings;

        systemd.user.services.lfbw = {
          Unit = {
            Description = "Linux Fake Background Webcam";
            After = [ "network.target" ];
            "X-Restart-Triggers" = [ config.xdg.configFile."lfbw/lfbw.ini".source ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.package} -c ${config.xdg.configHome}/lfbw/lfbw.ini";
            # lfbw exits on SIGQUIT (Ctrl+\), so that is the stop signal.
            KillSignal = "SIGQUIT";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
