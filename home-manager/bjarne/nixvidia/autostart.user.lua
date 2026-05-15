-- User-specific autostart configuration

local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Autostart on first launch (exec-once)
hl.on("hyprland.start", function()
  hl.exec_cmd("xembedsniproxy")
  hl.exec_cmd("sleep 1; systemctl --user start waybar.service")
  hl.exec_cmd("sleep 3; uwsm-app -- 1password --silent")
  hl.exec_cmd(scriptsDir .. "/auto-hide-wine-trays")
  hl.exec_cmd(scriptsDir .. "/monitor-config")
  hl.exec_cmd("systemctl restart --user hyprpaper.service")
end)

-- Continuous execution (exec)
hl.exec_cmd(scriptsDir .. "/monitor-config")
