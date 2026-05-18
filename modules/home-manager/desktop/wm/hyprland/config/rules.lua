-- Suppress maximize events for all windows
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
  },
  no_focus = true,
})

-- Window-specific rules
hl.window_rule({ match = { class = "feh" }, float = true })

-- Workspace rules
hl.workspace_rule({ workspace = "special", gaps_in = 24, gaps_out = 64 })
