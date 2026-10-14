{ lib, ... }:
{
  options.my.coding-agents = {
    claude-code.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install and configure Claude Code.";
    };
    copilot.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install and configure the GitHub Copilot CLI.";
    };
  };
}
