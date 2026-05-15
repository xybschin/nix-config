-- Host-specific bindings for nixvidia

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Monitor configuration menu
hl.bind(mainMod .. " + SHIFT + d", hl.dsp.exec_cmd(scriptsDir .. "/rofi-monitor-menu"))
