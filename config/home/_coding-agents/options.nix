{ lib, ... }:
let
  allAgents = [
    "claude"
    "copilot"
    "opencode"
  ];
in
{
  options.my.coding-agents.agents = lib.mkOption {
    type = lib.types.listOf (lib.types.enum allAgents);
    default = allAgents;
    description = ''
      Coding agents this host gets by default: each entry installs the
      agent's binary and writes its configuration (skills, MCP, themes).

      Overridable per rebuild without editing this file: the
      CODING_AGENTS environment variable (passed by `make home with=...`
      or read from the gitignored .feature-overrides file) wins when set;
      `none` selects an agent-less machine.
    '';
  };
}
