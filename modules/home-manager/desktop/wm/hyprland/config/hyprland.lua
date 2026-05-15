require("env")
require("settings")
require("binds")
require("rules")

hl.on("hyprland.start", function()
  hl.exec_cmd("sleep 3; 1password --silent")
end)
