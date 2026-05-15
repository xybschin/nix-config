-- User-specific Hyprland settings per monitor profile

local stateDir = os.getenv("HOME") .. "/.local/state"
local profileFile = stateDir .. "/hyprland-monitor-profile"
local profile = "profile1"

-- Try to read saved profile
local file = io.open(profileFile, "r")
if file then
  profile = file:read("*line")
  io.close(file)
end

-- Apply monitor configuration based on profile
if profile == "profile1" then
  -- Dual monitor setup
  hl.monitor({output = "DP-1", mode = "2560x1440@120", position = "0x0", scale = 1})
  hl.monitor({output = "HDMI-A-1", mode = "2560x1440@120", position = "2560x0", scale = 1})
elseif profile == "profile2" then
  -- Single HDMI (disable DP-1 by not configuring it)
  hl.monitor({output = "HDMI-A-1", mode = "2560x1440@120", position = "0x0", scale = 1})
elseif profile == "profile3" then
  -- Single DP-1 (disable HDMI-A-1 by not configuring it)
  hl.monitor({output = "DP-1", mode = "2560x1440@120", position = "0x0", scale = 1})
elseif profile == "profile4" then
  -- Ultrawide DP-1 (disable HDMI-A-1 by not configuring it)
  hl.monitor({output = "DP-1", mode = "5120x1440@144", position = "0x0", scale = 1})
end
