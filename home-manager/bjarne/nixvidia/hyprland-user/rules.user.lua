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
