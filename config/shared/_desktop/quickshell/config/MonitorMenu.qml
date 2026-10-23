import Quickshell
import Quickshell.Io

// Monitor-profile switcher. The profiles come from the
// `shared.desktop.monitors` feature, which writes
// ~/.config/koda/monitor-menu.json as [{ codepoint: "F5000", command: "…" }].
TileMenu {
    id: root
    namespace: "koda-monitormenu"
    ipcTarget: "monitormenu"

    function run(command) {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd("${command}")`])
    }

    FileView {
        id: file
        path: Theme.configHome + "/koda/monitor-menu.json"
        watchChanges: true
        onFileChanged: reload()
    }

    entries: {
        let profiles = []
        try {
            profiles = JSON.parse(file.text())
        } catch (e) {
            if (file.loaded)
                console.warn("MonitorMenu: cannot parse " + file.path + ": " + e)
        }
        return profiles.map(p => ({
            label: String.fromCodePoint(parseInt(p.codepoint, 16)),
            family: "MonitorIcons",
            activate: () => root.run(p.command)
        }))
    }
}
