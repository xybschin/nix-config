{ config, lib, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      autoupdate = false;
      lsp.nil = {
        command = [ "nil" ];
        extensions = [ ".nix" ];
        settings.nil.formatting.command = [ "nixfmt" ];
      };
    };
    tui = {
      theme = lib.mkForce "koda";
    };
    themes.koda = {
      "$schema" = "https://opencode.ai/theme.json";
      defs = {
        bg = c.base00;
        fg = c.base05;
        dim = c.base02;
        line = c.base01;
        keyword = c.base0E;
        type = c.base0A;
        operator = c.base04;
        comment = c.base03;
        border = c.base07;
        emphasis = c.base07;
        func = c.base0D;
        string = c.base0B;
        char = c.base0B;
        special = c.base0C;
        const = c.base09;
        highlight = c.base0D;
        info = c.base0C;
        success = c.base0B;
        warning = c.base0A;
        danger = c.base0F;
        green = c.base0B;
        orange = c.base09;
        red = c.base08;
        pink = c.base0E;
        cyan = c.base0C;
      };
      theme = {
        primary = "emphasis";
        secondary = "cyan";
        accent = "info";
        error = "danger";
        warning = "warning";
        success = "success";
        info = "info";
        text = "fg";
        textMuted = "keyword";
        selectedListItemText = "bg";
        background = "bg";
        backgroundPanel = "bg";
        backgroundElement = "line";
        border = "dim";
        borderActive = "emphasis";
        borderSubtle = "line";
        diffAdded = "success";
        diffRemoved = "danger";
        diffContext = "textMuted";
        diffHunkHeader = "info";
        diffHighlightAdded = "success";
        diffHighlightRemoved = "danger";
        diffAddedBg = "none";
        diffRemovedBg = "none";
        diffContextBg = "none";
        diffLineNumber = "keyword";
        markdownText = "fg";
        markdownHeading = "emphasis";
        markdownLink = "emphasis";
        markdownLinkText = "info";
        markdownCode = "const";
        markdownBlockQuote = "comment";
        markdownEmph = "emphasis";
        markdownStrong = "emphasis";
        markdownHorizontalRule = "dim";
        markdownListItem = "emphasis";
        markdownListEnumeration = "keyword";
        markdownImage = "cyan";
        markdownImageText = "cyan";
        markdownCodeBlock = "fg";
        syntaxComment = "comment";
        syntaxKeyword = "keyword";
        syntaxFunction = "func";
        syntaxVariable = "fg";
        syntaxString = "string";
        syntaxNumber = "const";
        syntaxType = "type";
        syntaxOperator = "operator";
        syntaxPunctuation = "keyword";
      };
    };
  };

  home.shellAliases.oc = "opencode";
}
