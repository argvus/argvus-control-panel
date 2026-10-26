import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleAppearance
    cardIcon:  "»"

    // Both switches show the saved state from Theme. While a toggle command is
    // running they show the requested state instead; if the command fails the
    // card falls back to the saved state on its own.
    property bool telemetryRequested: false
    property bool animationsRequested: false
    property bool effectsRequested: false
    readonly property bool widgetTelemetryEnabled: toggleProc.running ? telemetryRequested : Theme.widgetTelemetryEnabled
    // ANIMATIONS is the master switch for motion; EFFECTS is the master switch for
    // blur and transparency. They are independent, as `argvus effects-toggle
    // animations|effects` are.
    readonly property bool animationsOn: animationsToggleProc.running ? animationsRequested : Theme.animationsState !== "disabled"
    readonly property bool effectsOn: effectsToggleProc.running ? effectsRequested : Theme.effectsEnabled
    property string draftHex: ""

    // Changing the `effects` section makes argvus-config restart this panel,
    // which would kill a child process half way. Run the command as a transient
    // user unit instead (the same reason themeProc does) and wait for it.
    function detachedCommand(words) {
        return ["systemd-run", "--user", "--wait", "--collect", "--quiet",
            "--setenv=ARGVUS_CONFIG_HOME=" + Theme.configHome,
            "--setenv=ARGVUS_SYSTEM_CONFIG=" + Theme.systemConfig, "--"].concat(words)
    }

    function validHex(value) {
        return /^#?[0-9a-fA-F]{6}$/.test(value)
    }

    function normalizeHex(value) {
        var raw = value.charAt(0) === "#" ? value.substring(1) : value
        return "#" + raw.toUpperCase()
    }

    function colorToHex(color) {
        return "#" + [color.r, color.g, color.b].map(function (channel) {
            return Math.round(channel * 255).toString(16).padStart(2, "0")
        }).join("").toUpperCase()
    }

    // A user-selected highlight color is a canonical decision, not a runtime
    // detail. Persist `/appearance/accent` and `/appearance/accent_custom`
    // before the adapters run, otherwise the compositor keeps the per-theme
    // border color (hyprland.lua only honors the accent marker when the
    // canonical custom flag is set) and the next config projection would
    // re-derive the theme default.
    function accentPatch(color, isCustom) {
        var patch = { "/appearance/accent_custom": isCustom }
        if (color !== "") patch["/appearance/accent"] = color
        return JSON.stringify(patch)
    }

    function applyAccent() {
        if (accentProc.running || !validHex(draftHex)) return
        accentProc.command = accentApplyCommand(normalizeHex(draftHex), true)
        accentProc.running = true
    }

    // Persist first, then apply. `argvus-config patch` does not reproject, so
    // the ordering keeps the canonical document and the generated accent in
    // agreement. An empty color only clears the custom flag.
    function accentApplyCommand(color, isCustom) {
        var accentArgument = isCustom ? color : "--theme-default"
        return ["bash", "-c",
            "argvus config patch " + shellQuote(accentPatch(color, isCustom)) +
            " && exec argvus config accent " + shellQuote(accentArgument)]
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'"
    }

    Component.onCompleted: draftHex = colorToHex(Theme.accent)

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: "\uf03e"
            label: Strings.btnWallpaper
            onClicked: wallpaperProc.running = true
        }

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: ""
            label: Strings.btnTheme
            onClicked: themeProc.running = true
        }
    }

    Item { Layout.preferredHeight: 4 }

    GlassButton {
        Layout.fillWidth: true
        implicitHeight: 44
        iconText: ""
        label: Strings.btnAccent
        accentColor: Theme.accent
        onClicked: {
            accentDialog.selectedColor = Qt.color(draftHex)
            accentDialog.open()
        }
    }

    ColorDialog {
        id: accentDialog
        title: Strings.btnAccent
        selectedColor: Qt.color(Theme.accent)

        onAccepted: {
            draftHex = colorToHex(selectedColor)
            applyAccent()
        }
    }

    Connections {
        target: Theme
        function onThemeObjChanged() {
            draftHex = colorToHex(Theme.accent)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: widgetTelemetryToggleBtn
            width: 44; height: 24
            radius: Theme.radius

            color: widgetTelemetryEnabled ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                id: widgetTelemetryKnob
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: widgetTelemetryEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader

                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: widgetTelemetryToggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (toggleProc.running) return
                    telemetryRequested = !widgetTelemetryEnabled
                    toggleProc.running = true
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Strings.widgetTelemetryTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Text {
                text: widgetTelemetryEnabled ? Strings.widgetTelemetryEnabled : Strings.widgetTelemetryDisabled
                color: widgetTelemetryEnabled ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                opacity: 1
            }
        }

    }

    Item { Layout.preferredHeight: 2 }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: animationsToggleBtn
            width: 44; height: 24
            radius: Theme.radius
            color: animationsOn ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: animationsOn ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (animationsToggleProc.running) return
                    animationsRequested = !animationsOn
                    animationsToggleProc.running = true
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Text {
                text: Strings.animationsTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }
            Text {
                text: animationsOn ? Strings.animationsEnabled : Strings.animationsDisabled
                color: animationsOn ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: effectsToggleBtn
            width: 44; height: 24
            radius: Theme.radius
            color: effectsOn ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: effectsOn ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (effectsToggleProc.running) return
                    effectsRequested = !effectsOn
                    effectsToggleProc.running = true
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Text {
                text: Strings.effectsTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }
            Text {
                text: effectsOn ? Strings.effectsEnabled : Strings.effectsDisabled
                color: effectsOn ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
            }
        }
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/sh/hypr-wallpaper-pick.sh"]
    }

    Process {
        id: themeProc
        // The theme menu and the switch run outside this panel's service cgroup,
        // so a panel restart (a layout change) cannot end them. The switch calls
        // `ipc call theme reload` when the new theme is active.
        command: ["systemd-run", "--user", "--collect", "--quiet",
            "--setenv=ARGVUS_CONFIG_HOME=" + Theme.configHome,
            "--setenv=ARGVUS_SYSTEM_CONFIG=" + Theme.systemConfig,
            "--", "argvus", "theme-switch"]
        onExited: {
            Theme.reloadActiveTheme()
            Theme.reloadAccent()
        }
    }

    Process {
        id: accentProc
        // The real command is always assigned by applyAccent() before the
        // process is started. This default is the reversible theme-default
        // path so an unexpected start cannot damage other state.
        command: accentApplyCommand("", false)
        onExited: Theme.reloadAccent()
    }

    Process {
        id: toggleProc
        command: detachedCommand(["argvus", "widget-telemetry-toggle", "toggle"])
        onExited: Theme.refresh()
    }

    Process {
        id: animationsToggleProc
        command: detachedCommand(["argvus", "effects-toggle", "animations", "toggle"])
        onExited: Theme.refresh()
    }

    Process {
        id: effectsToggleProc
        command: detachedCommand(["argvus", "effects-toggle", "effects", "toggle"])
        onExited: Theme.refresh()
    }
}
