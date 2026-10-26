local function slugify(str)
	return (str:lower():gsub("%s+", "-"))
end

local GAMING_WORKSPACE = _G.GAMING_WORKSPACE
local hl = _G.hl
local GAME_TAG = "game"
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
			tag = "+" .. GAME_TAG,
		})
	end
end

local function is_game(w)
	for _, tag in ipairs(w.tags or {}) do
		if tag == GAME_TAG or tag == GAME_TAG .. "*" then
			return true
		end
	end
	return false
end

local function keep_off_gaming_workspace(w)
	if not GAMING_WORKSPACE or is_game(w) then
		return
	end
	local windows = hl.get_windows({ workspace = GAMING_WORKSPACE })
	local stray = false
	for _, gw in ipairs(windows) do
		if gw.address == w.address then
			stray = true
		end
	end
	if not stray then
		return
	end
	hl.dispatch(hl.dsp.window.move({ workspace = NON_GAMING_WORKSPACE, window = w, follow = true }))
	for _, gw in ipairs(windows) do
		if is_game(gw) and gw.fullscreen == 0 then
			hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = gw }))
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
