pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Palette and fonts, generated from Stylix by quickshell/default.nix into
// ~/.config/koda/theme.json (alpha already baked into each colour).
Singleton {
    id: root

    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")

    FileView {
        id: file
        path: root.configHome + "/koda/theme.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    readonly property var data: {
        try {
            return JSON.parse(file.text())
        } catch (e) {
            console.warn("Theme: cannot read " + file.path + ": " + e)
            return { colors: {}, font: {}, terminal: "" }
        }
    }

    readonly property color bg: data.colors.bg
    readonly property color border: data.colors.border
    readonly property color fg: data.colors.fg
    readonly property color fgDim: data.colors.fgDim
    readonly property color highlight: data.colors.highlight
    readonly property color accent: data.colors.accent

    readonly property string fontFamily: data.font.family
    readonly property real fontSize: data.font.size
    readonly property string tileFontFamily: data.font.tileFamily
    readonly property real tileFontSize: data.font.tileSize

    readonly property string terminal: data.terminal

    readonly property int radius: 3
    readonly property int radiusLg: 6
}
