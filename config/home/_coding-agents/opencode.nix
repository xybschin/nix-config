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
      theme = "koda";
    };
    themes.koda = {
      "$schema" = "https://opencode.ai/theme.json";
      defs = {
        bg = "#101010";
        fg = "#b0b0b0";
        dim = "#474747";
        line = "#272727";
        keyword = "#777777";
        type = "#777777";
        operator = "#777777";
        comment = "#50585d";
        border = "#ffffff";
        emphasis = "#ffffff";
        func = "#ffffff";
        string = "#ffffff";
        char = "#ffffff";
        special = "#ffffff";
        const = "#d9ba73";
        highlight = "#458ee6";
        info = "#8ebeec";
        success = "#86cd82";
        warning = "#d9ba73";
        danger = "#ff7676";
        green = "#14ba19";
        orange = "#ff5733";
        red = "#701516";
        pink = "#f2a4db";
        cyan = "#5abfb5";
      };
      theme = {
        primary = "highlight";
        secondary = "cyan";
        accent = "info";
        error = "danger";
        warning = "warning";
        success = "success";
        info = "info";
        text = "fg";
        textMuted = "keyword";
        selectedListItemText = "emphasis";
        background = "bg";
        backgroundPanel = "bg";
        backgroundElement = "line";
        border = "dim";
        borderActive = "highlight";
        borderSubtle = "line";
        diffAdded = "success";
        diffRemoved = "danger";
        diffContext = "textMuted";
        diffHunkHeader = "cyan";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "danger";
        diffAddedBg = "none";
        diffRemovedBg = "none";
        diffContextBg = "none";
        diffLineNumber = "keyword";
        markdownText = "fg";
        markdownHeading = "emphasis";
        markdownLink = "highlight";
        markdownLinkText = "info";
        markdownCode = "emphasis";
        markdownBlockQuote = "comment";
        markdownEmph = "emphasis";
        markdownStrong = "emphasis";
        markdownHorizontalRule = "dim";
        markdownListItem = "keyword";
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
