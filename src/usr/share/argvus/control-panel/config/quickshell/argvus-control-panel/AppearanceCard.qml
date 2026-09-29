import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleAppearance
    cardIcon:  "»"

    property bool widgetTelemetryEnabled: Theme.widgetTelemetryEnabled
    property bool animationsEnabled: Theme.animationsEnabled
    property string draftHex: ""

    function telemetryStateFromOutput(data) {
        const state = data.trim().toLowerCase()
        if (state === "enabled") return true
        if (state === "disabled") return false
        return widgetTelemetryEnabled
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

    function applyAccent() {
        if (accentProc.running || !validHex(draftHex)) return
        accentProc.command = [Theme.systemConfig + "/appearance/sh/accent-switch.sh", normalizeHex(draftHex)]
        accentProc.running = true
    }

    function resetAccent() {
        if (accentProc.running) return
        accentProc.command = [Theme.systemConfig + "/appearance/sh/accent-switch.sh", "--theme-default"]
        accentProc.running = true
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
        function onWidgetTelemetryEnabledChanged() {
            widgetTelemetryEnabled = Theme.widgetTelemetryEnabled
        }
        function onAnimationsStateChanged() {
            animationsEnabled = Theme.animationsEnabled
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        GlassButton { Layout.fillWidth: true; label: Strings.resetAccent; onClicked: resetAccent() }
    }

    Item { Layout.preferredHeight: 4 }

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
                    widgetTelemetryEnabled = !widgetTelemetryEnabled
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
            color: animationsEnabled ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: animationsEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: animationsToggleProc.running = true
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
                text: animationsEnabled ? Strings.animationsEnabled : Strings.animationsDisabled
                color: animationsEnabled ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
            }
        }
    }

    Timer {
        interval: 3000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!checkProc.running) checkProc.running = true
            if (!animationsStatusProc.running) animationsStatusProc.running = true
        }
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/sh/hypr-wallpaper-pick.sh"]
    }

    Process {
        id: themeProc
        // The theme switch restarts this panel. Run outside its service cgroup
        // so stopping the panel cannot kill the transition before DPMS resumes.
        command: ["systemd-run", "--user", "--collect", "--quiet",
            "--setenv=ARGVUS_CONFIG_HOME=" + Theme.configHome,
            "--setenv=ARGVUS_SYSTEM_CONFIG=" + Theme.systemConfig,
            "--", "sh", Theme.systemConfig + "/appearance/sh/theme-switch.sh"]
        onExited: {
            Theme.reloadActiveTheme()
            Theme.reloadAccent()
        }
    }

    Process {
        id: accentProc
        command: [Theme.systemConfig + "/appearance/sh/accent-switch.sh"]
        onExited: Theme.reloadAccent()
    }

    Process {
        id: toggleProc
        command: ["env", "ARGVUS_MACHINE_OUTPUT=1", "argvus-widget-telemetry-toggle", "toggle"]
        stdout: SplitParser {
            onRead: data => widgetTelemetryEnabled = telemetryStateFromOutput(data)
        }
    }

    Process {
        id: checkProc
        command: ["env", "ARGVUS_MACHINE_OUTPUT=1", "argvus-widget-telemetry-toggle", "status"]
        stdout: SplitParser {
            onRead: data => widgetTelemetryEnabled = telemetryStateFromOutput(data)
        }
    }

    Process {
        id: animationsToggleProc
        command: ["sh", Theme.systemConfig + "/session/sh/effects-toggle.sh", "animations", "toggle"]
        stdout: SplitParser {
            onRead: data => {
                animationsEnabled = data.trim() === "enabled"
                Theme.animationsState = animationsEnabled ? "enabled" : "disabled"
            }
        }
    }

    Process {
        id: animationsStatusProc
        command: ["sh", Theme.systemConfig + "/session/sh/effects-toggle.sh", "animations", "status"]
        stdout: SplitParser {
            onRead: data => {
                animationsEnabled = data.trim() === "enabled"
                Theme.animationsState = animationsEnabled ? "enabled" : "disabled"
            }
        }
    }

}
