import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    function setWallpaper(path) {
        applyProcess.running = false
        applyProcess.command = [
            "bash", "-c",
            `hyprctl hyprpaper wallpaper ",${path}" && ` +
            `printf "preload = %s\\nwallpaper = ,%s\\n" "${path}" "${path}" > "$HOME/.config/hypr/hyprpaper.conf"`
        ]
        applyProcess.running = true
    }

    function refreshWallpapers() {
        listProcess.running = false
        listProcess.running = true
    }

    Process {
        id: applyProcess
    }

    IpcHandler {
        target: "wallpaperBar"

        function toggle(): void {
            bar.visible = !bar.visible
            if (bar.visible) root.refreshWallpapers()
        }

        function show(): void {
            bar.visible = true
            root.refreshWallpapers()
        }

        function hide(): void {
            bar.visible = false
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
                    bar.wallpapers = parsed
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

    PanelWindow {
        id: bar

        property var wallpapers: []

        anchors {
          left: true
          right: true
          bottom: true
        }

        implicitHeight: 170
        color: "transparent"
        visible: true

        exclusiveZone: visible ? implicitHeight : 0

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            ListView {
                id: wallpaperList
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.bottomMargin: 0
                anchors.topMargin: 2
                orientation: ListView.Horizontal
                spacing: 1
                clip: true
                model: bar.wallpapers

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

                    width: height * 16 / 9
                    height: wallpaperList.height
                    color: "#101010"
                    border.width: 10
                    border.color: hoverArea.containsMouse ? "#777777" : "#272727"
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
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
                              root.setWallpaper(card.modelData.original)
                              bar.visible = false
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
