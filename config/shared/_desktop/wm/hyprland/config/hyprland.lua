require("colors")
require("env")
require("settings")
require("binds")
require("rules")

-- Load user-specific configurations if available
local function loadUserConfig(filename)
	local path = os.getenv("HOME") .. "/.config/hypr" .. "/" .. filename
	local file = io.open(path, "r")
	if file then
		io.close(file)
		dofile(path)
	end
end

loadUserConfig("monitors.lua")
loadUserConfig("settings.user.lua")
loadUserConfig("binds.user.lua")
loadUserConfig("rules.user.lua")
loadUserConfig("autostart.user.lua")

hl.on("hyprland.start", function() end)
