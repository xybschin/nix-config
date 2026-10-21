local mainMod = "SUPER"

hl.bind("CTRL + " .. mainMod .. " + d", hl.dsp.exec_cmd("rofi-monitor-menu"))
hl.bind("CTRL + " .. mainMod .. " + l", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + " .. mainMod .. " + w", hl.dsp.exec_cmd("quickshell ipc call wallpaperBar toggle"))
