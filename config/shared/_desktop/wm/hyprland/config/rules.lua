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

hl.window_rule({
	name = "floating-pip",
	match = {
		class = "brave-browser",
		title = "Picture-in-picture",
	},
	float = true,
	pin = true,
})

hl.layer_rule({
	match = { namespace = "^(waybar|rofi|swaync-.*)$" },
	blur = true,
	ignore_alpha = 0.5,
})
