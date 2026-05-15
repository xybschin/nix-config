require("env")
require("settings")
require("binds")
require("rules")

-- Load host-specific bindings if available
local hostBindsPath = os.getenv("HOME") .. "/.config/hypr/binds.nixvidia.lua"
if io.open(hostBindsPath, "r") then
  dofile(hostBindsPath)
end

hl.on("hyprland.start", function()
  hl.exec_cmd("sleep 3; 1password --silent")
end)
