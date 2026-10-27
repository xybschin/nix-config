local mainMod = "SUPER"

hl.bind("CTRL + " .. mainMod .. " + d", hl.dsp.exec_cmd("quickshell ipc call monitormenu toggle"))
hl.bind("CTRL + " .. mainMod .. " + w", hl.dsp.exec_cmd("quickshell ipc call wallpaperBar toggle"))
hl.bind(mainMod .. " + b", hl.dsp.exec_cmd("brave"))
