final: prev: {
  mcp-server-git = prev.mcp-server-git.overridePythonAttrs (old: {
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "mcp" ];
  });
}
