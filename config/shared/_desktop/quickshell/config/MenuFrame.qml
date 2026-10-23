import QtQuick

// The bordered, translucent box every menu sits in.
Rectangle {
    color: Theme.bg
    radius: Theme.radius
    border.width: 1
    border.color: Theme.border

    // Swallow clicks so only clicks outside the frame dismiss the menu.
    MouseArea {
        anchors.fill: parent
    }
}
