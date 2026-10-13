local function slugify(str)
	return str:lower():gsub("%s+", "-")
end

local function apply_game_window_rules(games)
	for _, game in ipairs(games) do
		hl.window_rule({
			name = slugify(game.name),
			match = game.match,
			border_size = 0,
			float = false,
			fullscreen = true,
			workspace = "10",
			render_unfocused = true,
		})
	end
end

apply_game_window_rules({
	{ name = "World of Warcraft", match = { title = "World of Warcraft" } },
	{ name = "Diablo IV", match = { title = "Diablo IV" } },
	{ name = "Steam Games", match = { class = "^steam_app_\\d+$" } },
})

-- Feh image viewer: floating, centered, 75% size
hl.window_rule({
	name = "feh",
	match = { class = "^feh$" },
	float = true,
	size = { "(monitor_w * 0.75)", "(monitor_h * 0.75)" },
	center = true,
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

hl.window_rule({
	match = { title = "^(Battle.net-Setup)$" },
	border_size = 0,
})
