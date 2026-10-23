import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// A centred menu on the focused monitor. Covers the screen with a transparent
// layer so a click outside the menu closes it, and takes exclusive keyboard
// focus while open. `content` is instantiated fresh on every open, so menus
// always start from a clean state.
Scope {
    id: root

    property string namespace: "koda-menu"
    property string ipcTarget: ""
    property Component content

    // Name of the monitor the menu is open on; empty when closed.
    property string activeMonitor: ""
    readonly property bool open: activeMonitor.length > 0

    // Keys the content did not consume; Escape is handled here.
    signal keyPressed(var event)

    function show() {
        let name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        if (name.length === 0) {
            Hyprland.refreshMonitors()
            name = Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
        }
        root.activeMonitor = name
    }

    function hide() {
        root.activeMonitor = ""
    }

    function toggle() {
        if (root.open)
            root.hide()
        else
            root.show()
    }

    IpcHandler {
        enabled: root.ipcTarget.length > 0
        target: root.ipcTarget

        function toggle(): void {
            root.toggle()
        }

        function show(): void {
            root.show()
        }

        function hide(): void {
            root.hide()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            readonly property bool active: root.activeMonitor === modelData.name

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: active

            WlrLayershell.namespace: root.namespace
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            MouseArea {
                anchors.fill: parent
                onClicked: root.hide()
            }

            Item {
                anchors.fill: parent
                focus: win.active

                Keys.onEscapePressed: root.hide()
                Keys.onPressed: event => root.keyPressed(event)

                Loader {
                    anchors.centerIn: parent
                    active: win.active
                    sourceComponent: root.content
                }
            }
        }
    }
}
