import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleAppearance
    cardIcon:  "»"

    property bool widgetTelemetryEnabled: false
    property bool effectsEnabled: true
    property var accentColors: ["#996548", "#3590bd", "#7391a5", "#17d174", "#cb17d1", "#d1174f", "#d1ce17", "#9617d1", "#595959"]

    function applyAccent(color) {
        if (accentProc.running) return
        accentProc.command = ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/accent-switch.sh '" + color + "'"]
        accentProc.running = true
    }

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
            if (accentProc.running) return
            accentProc.command = ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/accent-switch.sh"]
            accentProc.running = true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 5

        Repeater {
            model: accentColors

            Rectangle {
                required property string modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                radius: 3
                color: modelData
                border.width: Theme.accent.toString().toLowerCase() === modelData ? 2 : 1
                border.color: Theme.accent.toString().toLowerCase() === modelData ? Theme.fgText : Theme.borderSubtle

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: applyAccent(parent.modelData)
                }
            }
        }
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
                onClicked: toggleProc.running = true
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

        Text {
            text: widgetTelemetryEnabled ? "ON" : "OFF"
            color: widgetTelemetryEnabled ? Theme.accent : Theme.danger
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            font.letterSpacing: 2
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Item { Layout.preferredHeight: 2 }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: effectsToggleBtn
            width: 44; height: 24
            radius: Theme.radius

            color: effectsEnabled ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                id: effectsKnob
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: effectsEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader

                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: effectsToggleProc.running = true
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
                text: effectsEnabled ? Strings.effectsEnabled : Strings.effectsDisabled
                color: effectsEnabled ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                opacity: 1
            }
        }

        Text {
            text: effectsEnabled ? "ON" : "OFF"
            color: effectsEnabled ? Theme.accent : Theme.danger
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            font.letterSpacing: 2
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Timer {
        interval: 3000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!checkProc.running) checkProc.running = true
            if (!effectsStatusProc.running) effectsStatusProc.running = true
        }
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/apps/hypr-wallpaper-pick.sh"]
    }

    Process {
        id: themeProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/theme-switch.sh"]
        onExited: {
            Theme.reloadActiveTheme()
            Theme.reloadAccent()
        }
    }

    Process {
        id: accentProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/accent-switch.sh"]
        onExited: Theme.reloadAccent()
    }

    Process {
        id: toggleProc
        command: ["argvus-widget-telemetry-toggle", "toggle"]
        stdout: SplitParser {
            onRead: data => widgetTelemetryEnabled = data.trim() === "enabled"
        }
    }

    Process {
        id: checkProc
        command: ["argvus-widget-telemetry-toggle", "status"]
        stdout: SplitParser {
            onRead: data => widgetTelemetryEnabled = data.trim() === "enabled"
        }
    }

    Process {
        id: effectsToggleProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/effects-toggle.sh toggle"]
        stdout: SplitParser {
            onRead: data => {
                effectsEnabled = data.trim() === "enabled"
                Theme.effectsState = effectsEnabled ? "enabled" : "disabled"
            }
        }
    }

    Process {
        id: effectsStatusProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/effects-toggle.sh status"]
        stdout: SplitParser {
            onRead: data => {
                effectsEnabled = data.trim() === "enabled"
                Theme.effectsState = effectsEnabled ? "enabled" : "disabled"
            }
        }
    }
}
