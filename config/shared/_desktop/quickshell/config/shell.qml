import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    // Empty string means the bar is closed. Otherwise holds the name of the
    // Hyprland monitor the bar is currently open on.
    property string activeMonitor: ""
    property var wallpapers: []
    // Monitor name -> wallpaper path, so each display can keep its own pick.
    property var monitorWallpapers: ({})

    function setWallpaper(path, monitor) {
        if (!monitor || monitor.length === 0) return

        root.monitorWallpapers = Object.assign({}, root.monitorWallpapers, { [monitor]: path })

        let script = `mkdir -p "$HOME/.config/hypr" && printf '' > "$HOME/.config/hypr/hyprpaper.conf"`
        for (const mon in root.monitorWallpapers) {
            const p = root.monitorWallpapers[mon]
            script += ` && printf 'wallpaper {\\n  monitor = ${mon}\\n  path = %s\\n  fit_mode = cover\\n}\\n' "${p}" >> "$HOME/.config/hypr/hyprpaper.conf"`
        }
        script += ` && hyprctl hyprpaper wallpaper "${monitor},${path}"`

        applyProcess.running = false
        applyProcess.command = ["bash", "-c", script]
        applyProcess.running = true
    }

    function refreshWallpapers() {
        listProcess.running = false
        listProcess.running = true
    }

    function openBar(monitorName) {
        root.activeMonitor = (monitorName && monitorName.length > 0)
            ? monitorName
            : (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "")
        root.refreshWallpapers()
    }

    Process {
        id: applyProcess
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
            "find \"$HOME/wallpapers/single\" -type f " +
            "\\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.tiff' -o -iname '*.avif' \\) " +
            "-print0 | sort -z | tr '\\0' '\\n'"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(s => s.trim()).filter(s => s.length > 0)
                const parsed = lines.map(f => ({ original: f }))
                if (parsed.length > 0) {
                    root.wallpapers = parsed
                } else {
                    console.log("wallpaperBar: scan returned 0 results, keeping previous list")
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
                anchors.fill: parent
                color: "transparent"
                focus: bar.active

                Keys.onEscapePressed: root.activeMonitor = ""

                ListView {
                    id: wallpaperList
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.bottomMargin: 0
                    anchors.topMargin: 2
                    orientation: ListView.Horizontal
                    spacing: 2
                    clip: true
                    model: root.wallpapers

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
                        required property var modelData

                        width: Math.round(height * 16 / 9)
                        height: wallpaperList.height
                        color: "#101010"
                        border.width: 1
                        border.color: hoverArea.containsMouse ? "#777777" : "#272727"

                        Image {
                            anchors.fill: parent
                            anchors.margins: card.border.width
                            clip: true
                            source: (card.modelData && card.modelData.original) ? "file://" + card.modelData.original : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            cache: true
                            sourceSize.width: 320
                            sourceSize.height: 180
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (card.modelData && card.modelData.original) {
                                  root.setWallpaper(card.modelData.original, bar.modelData.name)
                                  root.activeMonitor = ""
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: wallpaperList.count === 0
                        text: "No wallpapers found in ~/wallpapers/single"
                        color: "#a6adc8"
                    }
                }
            }
        }
    }
}
