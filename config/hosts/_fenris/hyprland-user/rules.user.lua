local function slugify(str)
	return str:lower():gsub("%s+", "-")
end

local function apply_game_window_rules(titles)
	for _, title in ipairs(titles) do
		hl.window_rule({
			name = slugify(title),
			match = { title = title },
			border_size = 0,
			float = false,
			fullscreen = true,
			workspace = "10",
			render_unfocused = true,
		})
	end
end

apply_game_window_rules({
	"World of Warcraft",
	"Diablo IV",
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

hl.window_rule({
	match = { class = "^(signal)$" },
	workspace = "special:magic silent",
})

hl.window_rule({
	match = { class = "^(geary)$" },
	workspace = "special:magic silent",
})

hl.window_rule({
	match = { class = "^(spotify)$" },
	workspace = "special:magic silent",
})
