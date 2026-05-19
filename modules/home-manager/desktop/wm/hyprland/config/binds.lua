local mainMod = "SUPER"

-- Power controls
hl.bind(mainMod .. " + CTRL + s", hl.dsp.exec_cmd("hyprshutdown --post-cmd 'poweroff'"))
hl.bind(mainMod .. " + CTRL + r", hl.dsp.exec_cmd("hyprshutdown --post-cmd 'reboot'"))

-- Window/Session actions
hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + t", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + m", hl.dsp.exit())

-- Dwindle layout
hl.bind(mainMod .. " + o", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + p", hl.dsp.window.pseudo())

-- Lock screen
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + w", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + r", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + p", hl.dsp.exec_cmd("hyprpicker --autocopy"))

-- Application shortcuts
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + r", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + e", hl.dsp.exec_cmd("ghostty -e ranger ~"))
hl.bind(mainMod .. " + z", hl.dsp.exec_cmd("zen-twilight"))
hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("1password --quick-access"))

-- Special workspace
hl.bind(mainMod .. " + s", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move window focus with vim keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Swap windows with vim keys
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Center window
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.window.center())

-- Switch workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pulsemixer --change-volume +2"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pulsemixer --change-volume -2"), { repeating = true })
