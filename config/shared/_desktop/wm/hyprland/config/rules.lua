-- Suppress maximize events for all windows
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "1Password Quick Access",
	match = { class = "com.onepassword.OnePassword", float = true },
	center = true,
  stay_focused = true,
  pin = true,
})

-- Fix XWayland dragging issues
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
	},
	no_focus = true,
})

-- Workspace rules
hl.workspace_rule({
	workspace = "special:magic",
	gaps_in = 5,
	gaps_out = {
		top = 35,
		right = 35,
		bottom = 0,
		left = 35,
	},
})

hl.layer_rule({
	name = "rofi-blur",
	match = { namespace = "rofi" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "waybar-blur",
	match = { namespace = "waybar" },
	blur = true,
	ignore_alpha = 0.5,
})
