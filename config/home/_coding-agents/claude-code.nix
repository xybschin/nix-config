{ config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      includeCoAuthoredBy = false;
      theme = "custom:koda";
      statusLine = {
        type = "command";
        command = "~/.claude/statusline-koda.sh";
      };
    };
  };

  home.file.".claude/statusline-koda.sh" = {
    source = ./scripts/statusline-koda.sh;
    executable = true;
  };

  # Koda Dark terminal theme (base16 tokens from koda-dark.yaml; a few extra
  # dark/light tints in the same amber/red family fill in tokens with no
  # base16 slot, e.g. diff line backgrounds). Rainbow/subagent tokens are
  # left on the "dark" base preset since they need real hue diversity to
  # stay functionally distinguishable.
  home.file.".claude/themes/koda.json".text = builtins.toJSON {
    name = "Koda Dark";
    base = "dark";
    overrides = {
      claude = c.base0A;
      claudeShimmer = "#e8cf9c";
      text = c.base05;
      inverseText = c.base00;
      inactive = c.base04;
      inactiveShimmer = c.base08;
      subtle = c.base03;
      suggestion = c.base0A;
      permission = c.base07;
      permissionShimmer = c.base08;
      remember = c.base0A;

      success = c.base07;
      error = c.base0F;
      warning = c.base0A;
      warningShimmer = "#f2b98f";
      merged = c.base07;

      promptBorder = c.base02;
      promptBorderShimmer = c.base04;
      planMode = c.base07;
      autoAccept = c.base0A;
      bashBorder = c.base0F;
      ide = c.base0C;
      fastMode = c.base0C;
      fastModeShimmer = c.base08;

      diffAdded = "#332a18";
      diffRemoved = "#3a1616";
      diffAddedDimmed = "#201b10";
      diffRemovedDimmed = "#241010";
      diffAddedWord = c.base0A;
      diffRemovedWord = c.base0F;

      userMessageBackground = c.base01;
      userMessageBackgroundHover = c.base02;
      bashMessageBackgroundColor = "#241515";
      memoryBackgroundColor = "#241d12";
      selectionBg = c.base02;

      rate_limit_fill = c.base0A;
      rate_limit_empty = c.base01;
      briefLabelYou = c.base08;
      briefLabelClaude = c.base0A;
    };
  };

  home.shellAliases.cc = "claude";
}
