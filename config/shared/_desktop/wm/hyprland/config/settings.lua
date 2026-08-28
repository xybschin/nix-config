local C = require("colors")

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = { bottom = 0, left = 4, right = 4, top = 4 },
		border_size = 1,
		col = {
			active_border = C.base04,
			inactive_border = C.base01,
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 0,
		rounding_power = 1.0,
		active_opacity = 0.99,
		inactive_opacity = 0.97,
		dim_special = 0.6,
		blur = {
			enabled = true,
			size = 1,
			passes = 4,
			special = true,
		},
		shadow = { enabled = false },
	},
	animations = { enabled = false },
	input = {
		kb_layout = "eu",
		follow_mouse = 2,
		scroll_factor = 2,
	},
	dwindle = {
		preserve_split = true,
		force_split = 2,
		split_width_multiplier = 1.5,
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})
