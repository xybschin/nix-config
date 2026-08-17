{ lib, ... }:
{
  options.my = {
    configRoot = lib.mkOption {
      type = lib.types.str;
      default =
        let
          env = builtins.getEnv "CONFIG_ROOT";
        in
        if env != "" then env else builtins.getEnv "PWD";
      description = "Path to the repo root (for out-of-store symlinks).";
    };
    features = {
      nixos = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        default = { };
      };
      home = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        default = { };
      };
      darwin = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        default = { };
      };
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            system = lib.mkOption { type = lib.types.str; };
            username = lib.mkOption { type = lib.types.str; };
            isWsl = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            nixos = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  features = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                  extraModules = lib.mkOption {
                    type = lib.types.listOf lib.types.deferredModule;
                    default = [ ];
                  };
                  configuration = lib.mkOption {
                    type = lib.types.deferredModule;
                    default = { };
                  };
                };
              };
            };
            darwin = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  features = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                  extraModules = lib.mkOption {
                    type = lib.types.listOf lib.types.deferredModule;
                    default = [ ];
                  };
                  configuration = lib.mkOption {
                    type = lib.types.deferredModule;
                    default = { };
                  };
                };
              };
            };
            home = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  features = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                  extraModules = lib.mkOption {
                    type = lib.types.listOf lib.types.deferredModule;
                    default = [ ];
                  };
                  configuration = lib.mkOption {
                    type = lib.types.deferredModule;
                    default = { };
                  };
                };
              };
            };
          };
        }
      );
      default = { };
    };
  };
}
