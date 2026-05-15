require("env")
require("settings")

-- Load user-specific settings (monitor profiles, etc) if available
local configDir = os.getenv("HOME") .. "/.config/hypr"
local userSettingsPath = configDir .. "/settings.user.lua"
local userSettingsFile = io.open(userSettingsPath, "r")
if userSettingsFile then
  io.close(userSettingsFile)
  dofile(userSettingsPath)
end

require("binds")
require("rules")

-- Load user-specific configurations if available
local function loadUserConfig(filename)
  local path = configDir .. "/" .. filename
  local file = io.open(path, "r")
  if file then
    io.close(file)
    dofile(path)
  end
end

loadUserConfig("binds.user.lua")
loadUserConfig("rules.user.lua")
loadUserConfig("autostart.user.lua")

-- Default autostart (overridable by user config)
hl.on("hyprland.start", function()
  hl.exec_cmd("sleep 3; 1password --silent")
end)
