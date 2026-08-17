local C = require("colors")

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 1,
		col = {
			active_border = C.base0C,
			inactive_border = C.base01,
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 0,
		rounding_power = 1.0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		blur = { enabled = false },
		shadow = { enabled = false },
	},
	animations = { enabled = false },
	input = {
		kb_layout = "eu",
		follow_mouse = 2,
		accel_profile = "custom", --
		scroll_points = "0.1378592682 0.000 0.224 0.449 0.673 0.997 1.335 1.672 2.010 2.348 2.685 3.186 3.699 4.212 4.725 5.237 5.750 6.263 6.776 7.288 7.801 8.314 8.827 9.339 9.852 10.365 10.878 11.390 11.903 12.416 13.476",
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
