local state_file = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
	.. "/hyprland-monitor-profile"

local profile = "profile1"
local f = io.open(state_file, "r")
if f then
	profile = f:read("*line")
	f:close()
end

-- ---------------------------------------------------------------------------
-- Monitor layout
-- ---------------------------------------------------------------------------
if profile == "profile1" then
	hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "0x0", scale = 1 })
	hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@120", position = "2560x0", scale = 1 })
elseif profile == "profile2" then
	hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@120", position = "0x0", scale = 1 })
	hl.monitor({ output = "DP-1", disabled = true })
elseif profile == "profile3" then
	hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "0x0", scale = 1 })
	hl.monitor({ output = "HDMI-A-1", disabled = true })
elseif profile == "profile4" then
	hl.monitor({ output = "DP-1", mode = "5120x1440@144", position = "0x0", scale = 1 })
	hl.monitor({ output = "HDMI-A-1", disabled = true })
end

-- ---------------------------------------------------------------------------
-- Workspace assignment
-- ---------------------------------------------------------------------------
if profile == "profile1" then
	-- Odd workspaces on HDMI-A-1, even on DP-1
	for i = 1, 10 do
		if i % 2 == 1 then
			hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
		else
			hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
		end
	end
else
	local active = (profile == "profile2") and "HDMI-A-1" or "DP-1"
	for i = 1, 10 do
		hl.workspace_rule({ workspace = tostring(i), monitor = active })
	end
end
