import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    // QML singletons are created lazily on first access. Without touching the
    // Hyprland singleton here, its IPC connection (and therefore
    // Hyprland.focusedMonitor) would only be set up on the first `toggle`
    // call, making that first keybind press a no-op. Touch it at startup so
    // focusedMonitor is ready before the bar is ever opened.
    Component.onCompleted: Hyprland.focusedMonitor

    // Empty string means the bar is closed. Otherwise holds the name of the
    // Hyprland monitor the bar is currently open on.
    property string activeMonitor: ""
    property var wallpapers: []
    // Monitor name -> wallpaper path, so each display can keep its own pick.
    property var monitorWallpapers: ({})
    // Index of the keyboard-highlighted wallpaper while the bar is open.
    property int selectedIndex: 0
    // True between openBar() and the deferred first selection (firstSelectTimer)
    // being applied. While set, selection-driven repositioning is suppressed so
    // the list is not scrolled before it has laid out.
    property bool selectingInitial: false

    function moveSelection(delta) {
        const count = root.wallpapers.length
        if (count === 0) return
        root.selectedIndex = Math.max(0, Math.min(count - 1, root.selectedIndex + delta))
    }

    function activateSelection(monitor) {
        const wallpaper = root.wallpapers[root.selectedIndex]
        if (wallpaper && wallpaper.original) {
            root.setWallpaper(wallpaper.original, monitor)
            root.activeMonitor = ""
        }
    }

    function setWallpaper(path, monitor) {
        if (!monitor || monitor.length === 0) return

        root.monitorWallpapers = Object.assign({}, root.monitorWallpapers, { [monitor]: path })

        const confPath = "$HOME/.config/hypr/hyprpaper.conf"
        let script = `mkdir -p "$HOME/.config/hypr"`
        // If conf doesn't exist, create empty
        script += ` && [ -f "${confPath}" ] || : > "${confPath}"`
        // Remove any existing wallpaper block for this monitor (handle multi-line blocks)
        script += ` && python3 -c "
import sys
path = sys.argv[1]
mon = sys.argv[2]
try:
    with open(path) as f:
        content = f.read()
except Exception:
    content = ''
# Remove blocks for this monitor
import re
# Pattern: wallpaper { ... monitor = MONITOR ... } (non-greedy across lines)
pattern = re.compile(r'wallpaper\\s*\\{[^\\}]*monitor\\s*=\\s*' + re.escape(mon) + r'[^\\}]*\\}', re.DOTALL)
new_content = pattern.sub('', content).strip()
with open(path, 'w') as f:
    f.write(new_content + '\\n' if new_content else '')
" "${confPath}" "${monitor}"`
        // Append the new block for this monitor
        script += ` && printf 'wallpaper {\\n  monitor = ${monitor}\\n  path = %s\\n  fit_mode = cover\\n}\\n' "${path}" >> "${confPath}"`
        script += ` && hyprctl hyprpaper wallpaper "${monitor},${path},cover"`

        applyProcess.command = ["bash", "-c", script]
        if (!applyProcess.running)
            applyProcess.running = true
    }

    function refreshWallpapers() {
        listProcess.running = false
        listProcess.running = true
    }

    function openBar(monitorName) {
        let name = monitorName
        if (!name || name.length === 0) {
            name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        }
        if (!name || name.length === 0) {
            // focusedMonitor can still be unset on a very early press; nudge
            // Hyprland and fall back to the first connected screen so the bar
            // opens regardless.
            Hyprland.refreshMonitors()
            name = Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
        }
        // Select the first wallpaper shortly after the bar becomes visible
        // (see firstSelectTimer): changing it in the same iteration the layer
        // surface maps drops the border repaint until some other event forces
        // a frame. Deferring it makes the first card's highlight render.
        root.selectedIndex = -1
        root.selectingInitial = true
        root.activeMonitor = name
        root.refreshWallpapers()
    }

    Process {
        id: applyProcess

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("wallpaperBar apply stderr:", text)
                }
            }
        }
    }

    IpcHandler {
        target: "wallpaperBar"

        function toggle(): void {
            if (root.activeMonitor.length > 0) {
                root.activeMonitor = ""
            } else {
                root.openBar("")
            }
        }

        function show(): void {
            root.openBar("")
        }

        function hide(): void {
            root.activeMonitor = ""
        }
    }

    Process {
        id: listProcess
        command: [
            "bash", "-c",
            // -L: ~/wallpapers is an out-of-store symlink into the repo, and plain
            // find does not descend into a symlinked argument.
            "find -L \"$HOME/wallpapers\" -type f " +
            "\\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.tiff' -o -iname '*.avif' \\) " +
            "-print0 | sort -z | tr '\\0' '\\n'"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(s => s.trim()).filter(s => s.length > 0)
                const next = lines.map(f => ({ original: f }))
                // Only replace the model when the result actually differs.
                // Reassigning an equal list rebuilds the ListView, which races
                // the just-opened selection and makes the bar jump/repaint.
                const same = next.length === root.wallpapers.length
                    && next.every((w, i) => w.original === root.wallpapers[i].original)
                if (!same)
                    root.wallpapers = next
                if (next.length === 0) {
                    console.log("wallpaperBar: scan returned 0 results in ~/wallpapers")
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("wallpaperBar scan stderr:", text)
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            property bool active: root.activeMonitor === modelData.name

            anchors {
              left: true
              right: true
              bottom: true
            }

            implicitHeight: 170
            color: "transparent"
            visible: active

            exclusiveZone: active ? implicitHeight : 0

            WlrLayershell.keyboardFocus: active ? WlrLayershell.OnDemand : WlrLayershell.None

            Rectangle {
                id: keyArea
                anchors.fill: parent
                color: "transparent"
                focus: bar.active

                Keys.onEscapePressed: root.activeMonitor = ""
                Keys.onLeftPressed: root.moveSelection(-1)
                Keys.onRightPressed: root.moveSelection(1)
                Keys.onReturnPressed: root.activateSelection(bar.modelData.name)
                Keys.onEnterPressed: root.activateSelection(bar.modelData.name)

                Connections {
                    target: bar
                    function onActiveChanged() {
                        if (bar.active) {
                            keyArea.forceActiveFocus()
                            // Apply the deferred first selection once the
                            // window is up (see firstSelectTimer).
                            firstSelectTimer.restart()
                        }
                    }
                }

                // Defer the initial selection slightly: selecting in the same
                // iteration the layer surface maps can drop the border repaint.
                Timer {
                    id: firstSelectTimer
                    interval: 80
                    repeat: false
                    onTriggered: {
                        if (!bar.active) return
                        root.selectedIndex = 0
                        root.selectingInitial = false
                    }
                }

                Connections {
                    target: root
                    function onSelectedIndexChanged() {
                        if (!bar.active || root.selectedIndex < 0) return
                        if (root.selectingInitial) return
                        if (wallpaperList.count > 0 && wallpaperList.contentWidth > wallpaperList.width)
                            wallpaperList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }
                }

                Connections {
                    target: wallpaperList
                    function onCountChanged() {
                        if (bar.active && !root.selectingInitial && wallpaperList.count > 0
                                && root.selectedIndex >= 0 && wallpaperList.contentWidth > wallpaperList.width)
                            wallpaperList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }
                }

                ListView {
                    id: wallpaperList
                    anchors.fill: parent
                    anchors.topMargin: 2
                    orientation: ListView.Horizontal
                    spacing: 2
                    clip: true
                    // Populate only while open so the delegates (and their
                    // cached textures) are rebuilt on every open instead of
                    // being reused stale after the hidden surface released them.
                    model: bar.active ? root.wallpapers : []
                    // The list must never steal keyboard focus from keyArea,
                    // otherwise arrow keys scroll the view instead of moving
                    // the selection.
                    focus: false
                    keyNavigationEnabled: false

                    boundsBehavior: Flickable.StopAtBounds
                    boundsMovement: Flickable.StopAtBounds

                    WheelHandler {
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: event => {
                            let maxScroll = Math.max(0, wallpaperList.contentWidth - wallpaperList.width)
                            wallpaperList.contentX = Math.max(
                                0,
                                Math.min(
                                    maxScroll,
                                    wallpaperList.contentX - event.angleDelta.y
                                )
                            )
                        }
                    }

                    delegate: Rectangle {
                        id: card
                        // A delegate that declares any `required property` no
                        // longer receives the implicit `index`/`modelData`
                        // context properties, so `index` must be declared too.
                        required property int index
                        required property var modelData

                        readonly property bool selected: bar.active && index === root.selectedIndex

                        width: Math.round(height * 16 / 9)
                        // Fixed height rather than wallpaperList.height: the
                        // list's own size is not settled on the first layout
                        // pass, so sizing delegates from it left the first
                        // cards inconsistent.
                        height: bar.implicitHeight - 2
                        color: "#101010"
                        border.width: 1
                        border.color: selected ? "#d9ba73" : (hoverArea.containsMouse ? "#777777" : "#272727")

                        Item {
                            anchors.fill: parent
                            anchors.margins: card.border.width
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: (card.modelData && card.modelData.original) ? "file://" + card.modelData.original : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                                cache: true
                                sourceSize.width: 320
                                sourceSize.height: 180
                                // Subtle zoom on the selected thumbnail. It is
                                // scaled inside the clipped frame above so it
                                // never overflows the card or its 1px border.
                                scale: card.selected ? 1.12 : 1.0
                                transformOrigin: Item.Center
                                Behavior on scale {
                                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        // Dim the unselected cards while the bar is open so the
                        // highlighted one is obvious at a glance.
                        Rectangle {
                            anchors.fill: parent
                            color: "#101010"
                            opacity: bar.active && root.selectedIndex >= 0 && !card.selected ? 0.55 : 0.0
                            Behavior on opacity {
                                NumberAnimation { duration: 90 }
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (card.modelData && card.modelData.original) {
                                  root.selectedIndex = index
                                  root.setWallpaper(card.modelData.original, bar.modelData.name)
                                  root.activeMonitor = ""
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: wallpaperList.count === 0
                        text: "No wallpapers found in ~/wallpapers"
                        color: "#a6adc8"
                    }
                }
            }
        }
    }
}
