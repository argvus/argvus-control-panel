pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string themeName: "argvus-dark"
    property string gtkMode: "dark"
    property string animationsState: "enabled"
    property string controlPanelTransparencyState: "enabled"
    property int controlPanelTransparency: 50
    property string fontFamily: "IBM Plex Mono"
    property string monoFontFamily: "IBM Plex Mono"
    property int fontSize: 14
    property int monoFontSize: 14
    property bool bordersRounded: false
    property int bordersRounding: 0
    property bool widgetTelemetryEnabled: true
    property int sessionLockMinutes: 30
    property bool keepAwake: false
    property real audioVolume: 0.5
    property bool audioMuted: false
    readonly property string configHome: Quickshell.env("ARGVUS_CONFIG_HOME") ||
        StandardPaths.writableLocation(StandardPaths.GenericConfigLocation)
    readonly property string systemConfig: Quickshell.env("ARGVUS_SYSTEM_CONFIG") || "/usr/share/argvus"
    readonly property string generatedConfig: configHome + "/argvus/data/generated"

    FileView { id: appearanceConfigFile; path: root.configHome + "/argvus/config/appearance.json"; onTextChanged: root.loadAppearance(text()) }
    FileView { id: effectsConfigFile; path: root.configHome + "/argvus/config/effects.json"; onTextChanged: root.loadEffects(text()) }
    FileView { id: layoutConfigFile; path: root.configHome + "/argvus/config/layout.json"; onTextChanged: root.loadLayout(text()) }
    FileView { id: powerConfigFile; path: root.configHome + "/argvus/config/power.json"; onTextChanged: root.loadPower(text()) }
    FileView { id: audioConfigFile; path: root.configHome + "/argvus/config/audio.json"; onTextChanged: root.loadAudio(text()) }

    FileView {
        id: themeNameFile
        path: root.configHome + "/argvus/data/.active-theme"
        onTextChanged: {
            var n = text().trim()
            if (n !== "") root.themeName = n
        }
    }

    FileView {
        id: gtkModeFile
        path: root.configHome + "/argvus/data/.gtk-mode"
        onTextChanged: {
            var m = text().trim()
            if (m === "light" || m === "dark") root.gtkMode = m
        }
    }

    FileView {
        id: fontsFile
        path: root.configHome + "/argvus/data/generated/fonts.conf"
        onTextChanged: root.loadFonts(text())
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

        // 2. Generated config (~/.config/argvus/data/generated)
        themeFile.path = root.generatedConfig + "/quickshell/argvus-control-panel/themes/" +
            themeName + "/Theme.qml"
        themeFile.reload()
        if (themeFile.text().trim() !== "") return

        // 3. System default
        themeFile.path = root.systemConfig + "/control-panel/config/quickshell/argvus-control-panel/themes/" +
            themeName + "/Theme.qml"
        themeFile.reload()
    }

    function reloadActiveTheme() {
        themeNameFile.reload()
    }

    function reloadCanonicalConfig() {
        appearanceConfigFile.reload()
        effectsConfigFile.reload()
        layoutConfigFile.reload()
        powerConfigFile.reload()
        audioConfigFile.reload()
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

    function effectValue(contents, key, fallback) {
        var lines = contents.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf(key + "=") !== 0) continue
            var parsed = parseInt(line.substring(key.length + 1), 10)
            if (!isNaN(parsed)) return Math.min(Math.max(parsed, 0), 100)
        }
        return fallback
    }

    function loadEffectSettings(contents) {
        root.controlPanelTransparency = root.effectValue(
            contents, "control-panel.transparency", 50)
        root.controlPanelTransparencyState = root.effectState(
            contents, "control-panel.transparency.enabled", "enabled")
    }

    function parseSection(contents) {
        if (!contents || contents.trim() === "") return
        try { return JSON.parse(contents) } catch (error) { return null }
    }

    function loadAppearance(contents) {
        var appearance = parseSection(contents)
        if (!appearance) return
        if (typeof appearance.theme === "string" && appearance.theme !== "") root.themeName = appearance.theme
        if (appearance.gtk_mode === "light" || appearance.gtk_mode === "dark") root.gtkMode = appearance.gtk_mode
    }

    function loadEffects(contents) {
        var effects = parseSection(contents)
        if (!effects) return
        if (typeof effects.animations === "boolean") root.animationsState = effects.animations ? "enabled" : "disabled"
        if (typeof effects.widget_telemetry_enabled === "boolean") root.widgetTelemetryEnabled = effects.widget_telemetry_enabled
        if (typeof effects["transparency_control-panel_value"] === "number")
            root.controlPanelTransparency = Math.min(Math.max(effects["transparency_control-panel_value"], 0), 100)
        if (typeof effects["transparency_control-panel_enabled"] === "boolean")
            root.controlPanelTransparencyState = effects["transparency_control-panel_enabled"] ? "enabled" : "disabled"
    }

    function loadLayout(contents) {
        var layout = parseSection(contents)
        if (!layout) return
        var windowLayout = layout.window || {}
        var taskbar = layout.taskbar || {}
        if (typeof windowLayout.rounded === "boolean") root.bordersRounded = windowLayout.rounded
        if (typeof windowLayout.rounding === "number") root.bordersRounding = Math.min(Math.max(windowLayout.rounding, 0), 10)

        var top = Number(windowLayout.gaps_out_top)
        var right = Number(windowLayout.gaps_out_right)
        var bottom = Number(windowLayout.gaps_out_bottom)
        var left = Number(windowLayout.gaps_out_left)
        if (isNaN(top)) top = 0
        if (isNaN(right)) right = 0
        if (isNaN(bottom)) bottom = 0
        if (isNaN(left)) left = 0
        var taskbarTop = Number(taskbar.margin_top)
        var taskbarBottom = Number(taskbar.margin_bottom)
        if (isNaN(taskbarTop)) taskbarTop = 0
        if (isNaN(taskbarBottom)) taskbarBottom = 0
        if (taskbar.position === "top") top = Math.max(0, top - taskbarBottom)
        if (taskbar.position === "bottom") bottom = Math.max(0, bottom - taskbarTop)
        root._effectiveTop = top
        root._effectiveRight = right
        root._effectiveBottom = bottom
        root._effectiveLeft = left
    }

    function loadPower(contents) {
        var power = parseSection(contents)
        if (!power) return
        if (typeof power.lock_minutes === "number") root.sessionLockMinutes = Math.max(0, power.lock_minutes)
        if (typeof power.keep_awake === "boolean") root.keepAwake = power.keep_awake
    }

    function loadAudio(contents) {
        var audio = parseSection(contents)
        if (!audio) return
        if (typeof audio.output_volume === "number") root.audioVolume = Math.min(Math.max(audio.output_volume / 100.0, 0), 1)
        if (typeof audio.output_muted === "boolean") root.audioMuted = audio.output_muted
    }

    function effectState(contents, key, fallback) {
        var lines = contents.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf(key + "=") !== 0) continue
            var value = line.substring(key.length + 1).trim()
            if (value === "enabled" || value === "disabled") return value
        }
        return fallback
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
            root.reloadCanonicalConfig()
            fontsFile.reload()
        }
    }

    onThemeNameChanged: {
        loadTheme()
        root.reloadCanonicalConfig()
    }
    Component.onCompleted: {
        loadTheme()
        fontsFile.reload()
        root.reloadCanonicalConfig()
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
    function solidWhenTransparencyDisabled(c) {
        if (controlPanelTransparencyState === "disabled")
            return Qt.rgba(c.r, c.g, c.b, 1)
        var factor = Math.max(0, Math.min(1, (100 - controlPanelTransparency) / 100.0))
        return Qt.rgba(c.r, c.g, c.b, factor)
    }
    readonly property color bgPanel:         solidWhenTransparencyDisabled(modeColors ? modeColors.bgPanel : (themeObj ? themeObj.bgPanel   : "#b01e1e2e"))
    readonly property color bgCard:          solidWhenTransparencyDisabled(modeColors ? modeColors.bgCard  : (themeObj ? themeObj.bgCard    : "#b0313244"))
    readonly property color bgCardAlt:       solidWhenTransparencyDisabled(modeColors ? modeColors.bgCardAlt : (themeObj ? themeObj.bgCardAlt : "#b045475a"))
    readonly property color bgHeader:        solidWhenTransparencyDisabled(modeColors ? modeColors.bgHeader : (themeObj ? themeObj.bgHeader  : "#b011111b"))
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
    readonly property int borderRadius:      bordersRounded ? Math.min(Math.max(bordersRounding, 2), 10) : 0
    readonly property int radius:            borderRadius
    readonly property int radiusPill:        borderRadius
    readonly property int radiusSmall:       borderRadius
    readonly property bool animationsEnabled: animationsState !== "disabled"
    readonly property int animFast:          animationsEnabled ? (modeColors ? modeColors.animFast        : (themeObj ? themeObj.animFast       : 150)) : 0
    readonly property int animNormal:        animationsEnabled ? (modeColors ? modeColors.animNormal      : (themeObj ? themeObj.animNormal     : 220)) : 0
    property int _effectiveTop: 1
    property int _effectiveRight: 1
    property int _effectiveBottom: 1
    property int _effectiveLeft: 1
    readonly property int sidebarMarginTop: _effectiveTop
    readonly property int sidebarMarginRight: _effectiveRight
    readonly property int sidebarMarginBottom: _effectiveBottom
    readonly property int marginTop:         modeColors ? modeColors.marginTop       : (themeObj ? themeObj.marginTop      : 15)
    readonly property int marginBottom:      modeColors ? modeColors.marginBottom    : (themeObj ? themeObj.marginBottom   : 15)
    readonly property int marginRight:       modeColors ? modeColors.marginRight     : (themeObj ? themeObj.marginRight    : 15)
    readonly property int sidebarWidth:      modeColors ? modeColors.sidebarWidth    : (themeObj ? themeObj.sidebarWidth   : 350)
}
