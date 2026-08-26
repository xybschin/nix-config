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

-- Feh image viewer: floating, centered, 75% size
hl.window_rule({
	name = "feh",
	match = { class = "^feh$" },
	float = true,
	size = { "(monitor_w * 0.75)", "(monitor_h * 0.75)" },
	center = true,
})

-- XWayland opacity fix for floating windows without title/class
hl.window_rule({
	name = "xwayland-opacity-fix",
	match = {
		xwayland = true,
		title = "^$",
		class = "^xembedsniproxy$",
	},
	opacity = 0.0,
	float = true,
	no_blur = true,
	no_focus = true,
	size = { 0, 0 },
})

hl.windowrule("workspace special:magic silent", "class:^(geary)$")
hl.windowrule("workspace special:magic silent", "class:^(Signal)$")
hl.windowrule("workspace special:magic silent", "class:^(spotify)$")
