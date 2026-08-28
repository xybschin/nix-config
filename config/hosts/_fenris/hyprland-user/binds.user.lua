-- Host-specific bindings for fenris

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.bind(mainMod .. " + SHIFT + d", hl.dsp.exec_cmd(scriptsDir .. "/rofi-monitor-menu"))
hl.bind("CTRL + " .. mainMod .. " + l", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + " .. mainMod .. " + w", hl.dsp.exec_cmd("quickshell ipc call wallpaperBar toggle"))
