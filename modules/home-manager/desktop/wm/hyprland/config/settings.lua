hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,
    col = {
      active_border = "rgb(d9ba73)",
      inactive_border = "rgb(272727)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },
  decoration = {
    rounding = 0,
    rounding_power = 0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = { enabled = false },
    shadow = { enabled = false },
  },
  animations = { enabled = false },
  input = {
    kb_layout = "eu",
    follow_mouse = 2,
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
