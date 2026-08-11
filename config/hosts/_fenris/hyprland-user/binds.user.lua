-- Host-specific bindings for fenris

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Monitor configuration menu
hl.bind(mainMod .. " + SHIFT + d", hl.dsp.exec_cmd(scriptsDir .. "/rofi-monitor-menu"))

-- Lock screen on demand
hl.bind("CTRL + " .. mainMod .. " + l", hl.dsp.exec_cmd("hyprlock"))
