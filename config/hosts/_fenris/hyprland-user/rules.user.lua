local function slugify(str)
	return str:lower():gsub("%s+", "-")
end

local NON_GAMING_WORKSPACE = 1

local function apply_game_window_rules(games)
	for _, game in ipairs(games) do
		hl.window_rule({
			name = slugify(game.name),
			match = game.match,
			border_size = 0,
			float = false,
			fullscreen = true,
			workspace = GAMING_WORKSPACE and tostring(GAMING_WORKSPACE),
			render_unfocused = true,
			tag = "+game",
		})
	end
end

local function keep_off_gaming_workspace(w)
	if not GAMING_WORKSPACE then return end
	for _, tag in ipairs(w.tags or {}) do
		if tag == "game" then return end
	end
	for _, gw in ipairs(hl.get_windows({ workspace = GAMING_WORKSPACE })) do
		if gw.address == w.address then
			hl.dispatch(hl.dsp.window.move({ workspace = NON_GAMING_WORKSPACE, window = w, follow = false }))
			return
		end
	end
end

hl.on("window.open", keep_off_gaming_workspace)
hl.on("window.move_to_workspace", keep_off_gaming_workspace)

apply_game_window_rules({
	{ name = "World of Warcraft", match = { title = "World of Warcraft" } },
	{ name = "Diablo IV", match = { title = "Diablo IV" } },
	{ name = "Steam Games", match = { class = "^steam_app_\\d+$" } },
})

hl.window_rule({
	name = "feh",
	match = { class = "^feh$" },
	float = true,
	size = { "(monitor_w * 0.75)", "(monitor_h * 0.75)" },
	center = true,
})

hl.window_rule({
	match = { title = "^(Battle.net-Setup)$" },
	border_size = 0,
})

hl.window_rule({
	match = { title = "win11 on QEMU/KVM" },
	border_size = 0,
	float = true,
})
