require("env")
require("settings")
require("binds")
require("rules")

-- Load user-specific bindings if available
local userBindsPath = os.getenv("HOME") .. "/.config/hypr/binds.user.lua"
if io.open(userBindsPath, "r") then
  dofile(userBindsPath)
end

hl.on("hyprland.start", function()
  hl.exec_cmd("sleep 3; 1password --silent")
end)
