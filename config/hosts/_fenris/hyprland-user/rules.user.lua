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
	{ name = "Helldivers 2", match = { class = "steam_app_553850" } },
	{ name = "Hollow Knight", match = { class = "steam_app_367520" } },
	{ name = "Doom The Dark Ages", match = { class = "steam_app_3017860" } },
	{ name = "God of War", match = { class = "steam_app_1593500" } },
	{ name = "Ratchet And Clank", match = { class = "steam_app_1895880" } },
	{ name = "Hogwarts Legacy", match = { class = "steam_app_990080" } },
	{ name = "Elden Ring", match = { class = "steam_app_1245620" } },
	{ name = "REPO", match = { class = "steam_app_3241660" } },
	{ name = "Cyberpunk 2077", match = { class = "steam_app_1091500" } },
	{ name = "DRG Survivor", match = { class = "steam_app_2321470" } },
	{ name = "Witcher 3", match = { class = "steam_app_292030" } },
	{ name = "Party Animals", match = { class = "steam_app_1260320" } },
	{ name = "Portal 2", match = { class = "steam_app_620" } },
	{ name = "LEGO Harry Potter", match = { class = "steam_app_1004640" } },
	{ name = "Uncharted Legacy", match = { class = "steam_app_1659420" } },
	{ name = "Rogue Legacy 2", match = { class = "steam_app_1253920" } },
	{ name = "Borderlands 3", match = { class = "steam_app_397540" } },
	{ name = "RetroArch", match = { class = "retroarch" } },
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
