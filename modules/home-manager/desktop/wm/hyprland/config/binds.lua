-- Power controls
hl.bind("SUPER + CTRL + s", hl.dsp.exec_cmd("hyprshutdown --post-cmd 'poweroff'"))
hl.bind("SUPER + CTRL + r", hl.dsp.exec_cmd("hyprshutdown --post-cmd 'reboot'"))

-- Window/Session actions
hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + f", hl.dsp.window.fullscreen({}))
hl.bind("SUPER + t", hl.dsp.window.float({}))
hl.bind("SUPER + m", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Dwindle layout
hl.bind("SUPER + o", hl.dsp.exec_cmd("hyprctl dispatch togglesplit"))
hl.bind("SUPER + p", hl.dsp.window.pseudo({}))

-- Lock screen
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots
hl.bind("SUPER + SHIFT + w", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SUPER + SHIFT + r", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + p", hl.dsp.exec_cmd("hyprpicker --autocopy"))

-- Application shortcuts
hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + r", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + e", hl.dsp.exec_cmd("ghostty -e ranger ~"))
hl.bind("SUPER + z", hl.dsp.exec_cmd("zen-twilight"))
hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("1password --quick-access"))

-- Special workspace
hl.bind("SUPER + s", hl.dsp.workspace.focus({ id = "special" }))
hl.bind("SUPER + SHIFT + s", hl.dsp.window.move({ workspace = "special" }))

-- Move window focus with vim keys
hl.bind("SUPER + h", hl.dsp.window.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.window.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.window.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.window.focus({ direction = "d" }))

-- Swap windows with vim keys
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Center window
hl.bind("SUPER + SHIFT + c", hl.dsp.window.center({}))

-- Move monitor focus
hl.bind("SUPER + Tab", hl.dsp.monitor.focus({ direction = 1 }))

-- Switch workspaces
hl.bind("SUPER + 1", hl.dsp.workspace.focus({ id = 1 }))
hl.bind("SUPER + 2", hl.dsp.workspace.focus({ id = 2 }))
hl.bind("SUPER + 3", hl.dsp.workspace.focus({ id = 3 }))
hl.bind("SUPER + 4", hl.dsp.workspace.focus({ id = 4 }))
hl.bind("SUPER + 5", hl.dsp.workspace.focus({ id = 5 }))
hl.bind("SUPER + 6", hl.dsp.workspace.focus({ id = 6 }))
hl.bind("SUPER + 7", hl.dsp.workspace.focus({ id = 7 }))
hl.bind("SUPER + 8", hl.dsp.workspace.focus({ id = 8 }))
hl.bind("SUPER + 9", hl.dsp.workspace.focus({ id = 9 }))
hl.bind("SUPER + 0", hl.dsp.workspace.focus({ id = 10 }))

-- Move active window to a workspace
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move workspace between monitors
hl.bind("SUPER + CTRL + SHIFT + l", hl.dsp.workspace.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.workspace.move({ direction = "r" }))
hl.bind("SUPER + CTRL + SHIFT + h", hl.dsp.workspace.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + Left", hl.dsp.workspace.move({ direction = "l" }))

-- Mouse bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media controls
hl.bind(", XF86AudioRaiseVolume", hl.dsp.exec_cmd("pulsemixer --change-volume +2"), { repeating = true })
hl.bind(", XF86AudioLowerVolume", hl.dsp.exec_cmd("pulsemixer --change-volume -2"), { repeating = true })
