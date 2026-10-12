local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Autostart on first launch (exec-once)
hl.on("hyprland.start", function()
	hl.exec_cmd(scriptsDir .. "/monitor-config")
	hl.exec_cmd('faugus-launcher --game "Battle.net (Autostart)"')
end)
