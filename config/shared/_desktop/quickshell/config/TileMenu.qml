import QtQuick

// A row of big tiles. `entries` is a list of
// { label: string, family?: string, activate: function }.
Overlay {
    id: root

    property var entries: []
    property int selected: 0

    // One tile per entry, so there are never empty slots. Capped at the
    // widest layout the menu may use; extra entries wrap onto more rows.
    readonly property int maxColumns: 5
    readonly property int columns: Math.max(1, Math.min(entries.length, maxColumns))
    readonly property int tileSize: 90
    readonly property int padding: 4
    readonly property int spacing: 4
    readonly property int menuWidth: 2 + 2 * padding + columns * tileSize + (columns - 1) * spacing

    onOpenChanged: {
        if (open)
            selected = 0
    }

    function activate(index) {
        const entry = entries[index]
        if (!entry)
            return
        hide()
        entry.activate()
    }

    function move(delta) {
        selected = Math.max(0, Math.min(entries.length - 1, selected + delta))
    }

    onKeyPressed: event => {
        switch (event.key) {
        case Qt.Key_Left:
        case Qt.Key_H:
        case Qt.Key_Backtab:
            move(-1)
            break
        case Qt.Key_Right:
        case Qt.Key_L:
        case Qt.Key_Tab:
            move(1)
            break
        case Qt.Key_Up:
        case Qt.Key_K:
            move(-columns)
            break
        case Qt.Key_Down:
        case Qt.Key_J:
            move(columns)
            break
        case Qt.Key_Return:
        case Qt.Key_Enter:
            activate(selected)
            break
        default:
            return
        }
        event.accepted = true
    }

    content: Component {
        MenuFrame {
            width: root.menuWidth
            height: grid.height + 2 * root.padding + 2

            Grid {
                id: grid
                x: 1 + root.padding
                y: 1 + root.padding
                columns: root.columns
                spacing: root.spacing

                Repeater {
                    model: root.entries

                    Rectangle {
                        id: tile
                        required property int index
                        required property var modelData

                        readonly property bool selected: index === root.selected

                        width: root.tileSize
                        height: root.tileSize
                        radius: Theme.radius
                        color: selected ? Theme.highlight : Theme.bg
                        border.width: 1
                        border.color: selected ? Theme.fgDim : "transparent"

                        Text {
                            id: label
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: tile.modelData.label
                            color: tile.selected ? Theme.accent : Theme.fg
                            font.family: tile.modelData.family || Theme.tileFontFamily
                            font.pointSize: Theme.tileFontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.selected = tile.index
                            onClicked: root.activate(tile.index)
                        }
                    }
                }
            }
        }
    }
}
