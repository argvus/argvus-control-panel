pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string themeName: "argvus-dark-aether"
    property string gtkMode: "dark"
    property string effectsState: "enabled"
    property string fontFamily: "IBM Plex Mono"
    property string monoFontFamily: "IBM Plex Mono"
    property int fontSize: 14
    property int monoFontSize: 14
    readonly property string configHome: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation)
    readonly property string generatedConfig: configHome + "/argvus/generated"
    FileView {
        id: themeNameFile
        path: root.configHome + "/argvus/.active-theme"
        onTextChanged: {
            var n = text().trim()
            if (n !== "") root.themeName = n
        }
    }

    FileView {
        id: gtkModeFile
        path: root.configHome + "/argvus/.gtk-mode"
        onTextChanged: {
            var m = text().trim()
            if (m === "light" || m === "dark") root.gtkMode = m
        }
    }

    FileView {
        id: effectsStateFile
        path: root.configHome + "/argvus/state/effects"
        onTextChanged: {
            var s = text().trim()
            root.effectsState = s === "disabled" ? "disabled" : "enabled"
        }
    }

    FileView {
        id: fontsFile
        path: root.configHome + "/argvus/fonts.conf"
        onTextChanged: root.loadFonts(text())
    }

    // Mirrors the top waybar's horizontal margin so the sidebar stays
    // x-aligned with it (source of truth: waybar/argvus-taskbar.jsonc, rewritten
    // by theme-switch.sh and spaces-switch.sh).
    FileView {
        id: waybarMarginFile
        path: root.configHome + "/argvus/waybar/argvus-taskbar.jsonc"
        onTextChanged: {
            var m = text().match(/"margin-right":\s*(-?\d+)/)
            if (m) root._waybarMarginRight = parseInt(m[1], 10)
        }
    }

    property var themeObj: null

    FileView {
        id: themeFile
        blockLoading: true
        onTextChanged: {
            var qml = text().trim()
            if (qml === "") return
            var obj = Qt.createQmlObject(qml, root, "themeLoader")
            if (obj) {
                if (root.themeObj && root.themeObj !== obj) root.themeObj.destroy()
                root.themeObj = obj
            }
        }
    }

    function loadTheme() {
        // 1. User config (~/.config/argvus) — where accent-switch writes accent colors
        themeFile.path = root.configHome + "/argvus/quickshell/argvus-control-panel/themes/" +
            themeName + "/Theme.qml"
        themeFile.reload()
        if (themeFile.text().trim() !== "") return

        // 2. Generated config (~/.config/argvus/config)
        themeFile.path = root.generatedConfig + "/quickshell/argvus-control-panel/themes/" +
            themeName + "/Theme.qml"
        themeFile.reload()
        if (themeFile.text().trim() !== "") return

        // 3. System default
        themeFile.path = "/usr/share/argvus/control-panel/config/quickshell/argvus-control-panel/themes/" +
            themeName + "/Theme.qml"
        themeFile.reload()
    }

    function reloadActiveTheme() {
        themeNameFile.reload()
    }

    function reloadAccent() { themeFile.reload() }

    function fontValue(contents, key, fallback) {
        var lines = contents.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "" || line[0] === "#") continue
            var eq = line.indexOf("=")
            if (eq <= 0) continue
            if (line.substring(0, eq).trim() === key) {
                var value = line.substring(eq + 1).trim()
                return value === "" ? fallback : value
            }
        }
        return fallback
    }

    function loadFonts(contents) {
        root.fontFamily = fontValue(contents, "control_panel_family", fontValue(contents, "default_family", "IBM Plex Mono"))
        root.monoFontFamily = fontValue(contents, "control_panel_family", fontValue(contents, "monospace_family", root.fontFamily))
        root.fontSize = parseInt(fontValue(contents, "control_panel_size", fontValue(contents, "default_size", "14")), 10)
        root.monoFontSize = parseInt(fontValue(contents, "control_panel_size", fontValue(contents, "monospace_size", "14")), 10)
        if (isNaN(root.fontSize) || root.fontSize < 8) root.fontSize = 14
        if (isNaN(root.monoFontSize) || root.monoFontSize < 8) root.monoFontSize = root.fontSize
    }

    function scaledFont(baseSize) {
        var scale = Math.max(0.7, Math.min(1.8, root.fontSize / 13.0))
        return Math.max(8, Math.round(baseSize * scale))
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            themeNameFile.reload()
            gtkModeFile.reload()
            effectsStateFile.reload()
            fontsFile.reload()
            waybarMarginFile.reload()
        }
    }

    onThemeNameChanged: loadTheme()
    Component.onCompleted: {
        loadTheme()
        fontsFile.reload()
    }

    // modeColors — non-null when theme declares a `light` QtObject and gtkMode is "light"
    readonly property var modeColors: gtkMode === "light" && themeObj && themeObj.light
        ? themeObj.light : null

    readonly property color accent:          themeObj ? themeObj.accent          : "#3590bd"
    readonly property color accentDim:       themeObj ? themeObj.accentDim       : "#223590bd"
    readonly property color accentMid:       themeObj ? themeObj.accentMid       : "#553590bd"
    readonly property color accentFaint:     themeObj ? themeObj.accentFaint     : "#0f3590bd"
    readonly property color accentLight:     themeObj ? themeObj.accentLight     : "#3590bd"
    readonly property color fgTitle:         themeObj ? themeObj.fgTitle         : "#3590bd"
    readonly property color fgText:          modeColors ? modeColors.fgText          : (themeObj ? themeObj.fgText         : "#cdd6f4")
    readonly property color fgDim:           modeColors ? modeColors.fgDim           : (themeObj ? themeObj.fgDim          : "#bac2de")
    readonly property color fgSubtle:        modeColors ? modeColors.fgSubtle        : (themeObj ? themeObj.fgSubtle       : "#a6adc8")
    readonly property color fgFaint:         modeColors ? modeColors.fgFaint         : (themeObj ? themeObj.fgFaint        : "#6c7086")
    readonly property color fgOnAccent:      themeObj ? themeObj.fgOnAccent      : "#111316"
    readonly property color bg:              modeColors ? modeColors.bg              : (themeObj ? themeObj.bg             : "#1e1e2e")
    readonly property color bgPanel:         modeColors ? modeColors.bgPanel         : (themeObj ? themeObj.bgPanel        : "#b01e1e2e")
    readonly property color bgCard:          modeColors ? modeColors.bgCard          : (themeObj ? themeObj.bgCard         : "#b0313244")
    readonly property color bgCardAlt:       modeColors ? modeColors.bgCardAlt       : (themeObj ? themeObj.bgCardAlt      : "#b045475a")
    readonly property color bgHeader:        modeColors ? modeColors.bgHeader        : (themeObj ? themeObj.bgHeader       : "#b011111b")
    readonly property color bgItem:          modeColors ? modeColors.bgItem          : (themeObj ? themeObj.bgItem         : "#0acdd6f4")
    readonly property color bgItemHover:     modeColors ? modeColors.bgItemHover     : (themeObj ? themeObj.bgItemHover    : "#14cdd6f4")
    readonly property color bgActive:        themeObj ? themeObj.bgActive        : "#223590bd"
    readonly property color border:          themeObj ? themeObj.border          : "#223590bd"
    readonly property color borderStrong:    themeObj ? themeObj.borderStrong    : "#553590bd"
    readonly property color borderItem:      themeObj ? themeObj.borderItem      : "#0f3590bd"
    readonly property color borderSubtle:    modeColors ? modeColors.borderSubtle    : (themeObj ? themeObj.borderSubtle   : "#45475a")
    readonly property color scrollbarFg:     modeColors ? modeColors.scrollbarFg     : (themeObj ? themeObj.scrollbarFg    : "#cdd6f4")
    readonly property color scrollbarBg:     modeColors ? modeColors.scrollbarBg     : (themeObj ? themeObj.scrollbarBg    : "#45475a")
    readonly property color danger:          modeColors ? modeColors.danger          : (themeObj ? themeObj.danger         : "#f38ba8")
    readonly property color dangerDim:       modeColors ? modeColors.dangerDim       : (themeObj ? themeObj.dangerDim      : "#f38ba866")
    readonly property color warn:            modeColors ? modeColors.warn            : (themeObj ? themeObj.warn           : "#f9e2af")
    readonly property color ok:              modeColors ? modeColors.ok              : (themeObj ? themeObj.ok             : "#a6e3a1")
    readonly property string fontMono:       monoFontFamily
    readonly property string fontIcon:       "Symbols Nerd Font Mono"
    readonly property int radius:            modeColors ? modeColors.radius          : (themeObj ? themeObj.radius         : 8)
    readonly property int radiusPill:        modeColors ? modeColors.radiusPill      : (themeObj ? themeObj.radiusPill     : 18)
    readonly property int radiusSmall:       modeColors ? modeColors.radiusSmall     : (themeObj ? themeObj.radiusSmall    : 4)
    readonly property bool effectsEnabled:   effectsState !== "disabled"
    readonly property int animFast:          effectsEnabled ? (modeColors ? modeColors.animFast        : (themeObj ? themeObj.animFast       : 150)) : 0
    readonly property int animNormal:        effectsEnabled ? (modeColors ? modeColors.animNormal      : (themeObj ? themeObj.animNormal     : 220)) : 0
    property int _waybarMarginRight: 0
    readonly property int waybarMarginRight: _waybarMarginRight
    readonly property int marginTop:         modeColors ? modeColors.marginTop       : (themeObj ? themeObj.marginTop      : 15)
    readonly property int marginBottom:      modeColors ? modeColors.marginBottom    : (themeObj ? themeObj.marginBottom   : 15)
    readonly property int marginRight:       modeColors ? modeColors.marginRight     : (themeObj ? themeObj.marginRight    : 15)
    readonly property int sidebarWidth:      modeColors ? modeColors.sidebarWidth    : (themeObj ? themeObj.sidebarWidth   : 350)
}
