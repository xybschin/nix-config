-- Window rules
hl.window_rule({ match = { class = "feh" }, float = true })

-- Layer rules for waybar
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0 })

-- Workspace rules
hl.workspace_rule({ workspace = "special", gaps_in = 24, gaps_out = 64 })
