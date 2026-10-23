import QtQuick
import Quickshell

// Application launcher.
Overlay {
    id: root
    namespace: "koda-launcher"
    ipcTarget: "launcher"

    readonly property int rows: 6
    readonly property int rowHeight: 58
    readonly property int rowSpacing: 4

    property string query: ""
    property int selected: 0

    readonly property var tokens: query.toLowerCase().split(/\s+/).filter(t => t.length > 0)

    // Matches on name and generic name.
    readonly property var results: Array.from(DesktopEntries.applications.values)
        .filter(e => !e.noDisplay && tokens.every(t =>
            e.name.toLowerCase().includes(t) || e.genericName.toLowerCase().includes(t)))
        .sort((a, b) => a.name.localeCompare(b.name))

    onOpenChanged: {
        if (open) {
            query = ""
            selected = 0
        }
    }

    function launch(entry) {
        if (!entry)
            return
        hide()
        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: [Theme.terminal, "-e", ...Array.from(entry.command)],
                workingDirectory: entry.workingDirectory
            })
        } else {
            entry.execute()
        }
    }

    function move(delta, wrap) {
        const count = results.length
        if (count === 0)
            return
        selected = wrap
            ? (selected + delta + count) % count
            : Math.max(0, Math.min(count - 1, selected + delta))
    }

    function iconSource(entry) {
        if (entry.icon.startsWith("/"))
            return "file://" + entry.icon
        return Quickshell.iconPath(entry.icon, true) || Quickshell.iconPath("application-x-executable")
    }

    // Name as StyledText with the matched parts bold and underlined.
    function markup(text) {
        const lower = text.toLowerCase()
        const marked = new Array(text.length).fill(false)
        for (const token of tokens) {
            let at = lower.indexOf(token)
            while (at >= 0) {
                for (let i = at; i < at + token.length; i++)
                    marked[i] = true
                at = lower.indexOf(token, at + token.length)
            }
        }
        let out = ""
        let inMatch = false
        for (let i = 0; i < text.length; i++) {
            if (marked[i] !== inMatch) {
                out += inMatch ? "</u></b>" : "<b><u>"
                inMatch = marked[i]
            }
            out += text[i] === "&" ? "&amp;" : text[i] === "<" ? "&lt;" : text[i] === ">" ? "&gt;" : text[i]
        }
        return inMatch ? out + "</u></b>" : out
    }

    onKeyPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (ctrl && event.key === Qt.Key_P))
            move(-1, true)
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || (ctrl && event.key === Qt.Key_N))
            move(1, true)
        else if (event.key === Qt.Key_PageUp)
            move(-rows, false)
        else if (event.key === Qt.Key_PageDown)
            move(rows, false)
        else
            return
        event.accepted = true
    }

    content: Component {
        MenuFrame {
            width: 720
            height: inputBar.height + 1 + list.height
            radius: Theme.radiusLg

            Item {
                id: inputBar
                x: 1
                y: 1
                width: parent.width - 2
                height: input.implicitHeight + 32

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.margins: 16
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fgDim
                    selectionColor: Theme.highlight
                    selectedTextColor: Theme.accent
                    font.family: Theme.fontFamily
                    font.pointSize: Theme.fontSize
                    clip: true
                    focus: true

                    onTextChanged: {
                        root.query = text
                        root.selected = 0
                    }
                    onAccepted: root.launch(root.results[root.selected])

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: input.text.length === 0
                        text: "Search..."
                        color: Theme.fgDim
                        font: input.font
                    }
                }
            }

            Rectangle {
                x: 1
                y: inputBar.y + inputBar.height
                width: parent.width - 2
                height: 1
                color: Theme.border
            }

            ListView {
                id: list
                x: 1
                y: inputBar.y + inputBar.height + 1
                width: parent.width - 2
                height: root.rows * root.rowHeight + (root.rows - 1) * root.rowSpacing + 6
                spacing: root.rowSpacing
                clip: true
                interactive: false
                model: root.results
                boundsBehavior: Flickable.StopAtBounds

                Connections {
                    target: root
                    function onSelectedChanged() {
                        list.positionViewAtIndex(root.selected, ListView.Contain)
                    }
                }

                delegate: Item {
                    id: row
                    required property int index
                    required property var modelData

                    readonly property bool selected: index === root.selected

                    width: ListView.view.width
                    height: root.rowHeight

                    Rectangle {
                        x: 12
                        y: 6
                        width: parent.width - 24
                        height: 52
                        radius: Theme.radius
                        color: row.selected ? Theme.highlight : "transparent"
                        border.width: 1
                        border.color: row.selected ? Theme.fgDim : "transparent"

                        Image {
                            id: icon
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            height: 32
                            sourceSize: Qt.size(32, 32)
                            source: root.iconSource(row.modelData)
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.left: icon.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            textFormat: row.selected ? Text.StyledText : Text.PlainText
                            text: row.selected ? root.markup(row.modelData.name) : row.modelData.name
                            color: row.selected ? Theme.accent : Theme.fg
                            font.family: Theme.fontFamily
                            font.pointSize: Theme.fontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.selected = row.index
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }
            }
        }
    }
}
