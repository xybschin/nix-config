-- User-specific window and layer rules for gaming

-- Game-specific rules
hl.window_rule({
  name = "world-of-warcraft",
  match = { title = "World of Warcraft" },
  border_size = 0,
  float = false,
})

hl.window_rule({
  name = "diablo-iv",
  match = { title = "Diablo IV" },
  border_size = 0,
  float = false,
})

-- wine-sni-bridge: X11-to-SNI tray bridge
hl.window_rule({
  name = "wine-sni-bridge",
  match = { class = "wine-sni-bridge" },
  float = true,
  no_focus = true,
  opacity = 0.0,
  border_size = 0,
  no_blur = true,
  no_shadow = true,
  no_anim = true,
})

-- XWayland opacity fix for floating windows without title/class
hl.window_rule({
  name = "xwayland-opacity-fix",
  match = {
    xwayland = true,
    title = "^$",
    class = "^$",
  },
  opacity = 0.0,
  float = true,
  no_blur = true,
})
