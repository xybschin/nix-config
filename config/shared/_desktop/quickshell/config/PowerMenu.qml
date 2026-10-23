import Quickshell

TileMenu {
    namespace: "koda-powermenu"
    ipcTarget: "powermenu"

    // Run through Hyprland so the command lives outside quickshell's own
    // service.
    function run(command) {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd("${command}")`])
    }

    entries: [
        {
            label: String.fromCodePoint(0xF0425),
            activate: () => run("hyprshutdown -t 'Shutting down...' --post-cmd 'systemctl poweroff'")
        },
        {
            label: String.fromCodePoint(0xF0709),
            activate: () => run("hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot'")
        },
        {
            label: String.fromCodePoint(0xF033E),
            activate: () => run("hyprlock")
        },
        {
            label: String.fromCodePoint(0xF0343),
            activate: () => run("hyprshutdown")
        }
    ]
}
