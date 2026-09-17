import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    id: card
    cardTitle: Strings.cardTitleBorders
    cardIcon: "»"

    property bool rounded: false
    property int rounding: 0

    readonly property string script: "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/hyprland/sh/borders-switch.sh"
    readonly property string reloadScript: "argvus-sessionctl reload"

    Timer {
        interval: 2000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!statusProc.running) statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["bash", "-c", card.script + " --status"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("=")
                    if (parts.length !== 2) continue
                    if (parts[0] === "rounded") card.rounded = parts[1] === "1"
                    if (parts[0] === "rounding") card.rounding = parseInt(parts[1])
                }
            }
        }
    }

    Process {
        id: setProc
        property string cmd: ""
        command: ["sh", "-c", cmd]
    }

    Process {
        id: applyProc
        command: ["sh", "-c", card.reloadScript]
    }

    function setValue(key, value) {
        setProc.cmd = card.script + " --set " + key + " " + value
        setProc.running = true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 44; height: 24
                radius: Theme.radius
                color: card.rounded ? Theme.accent : Theme.borderSubtle
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Rectangle {
                    width: 18; height: 18
                    radius: Math.max(2, Theme.radius)
                    x: card.rounded ? parent.width - width - 3 : 3
                    y: (parent.height - height) / 2
                    color: Theme.bgHeader

                    Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        card.rounded = !card.rounded
                        if (card.rounded && card.rounding < 2) card.rounding = 2
                        setValue("rounded", card.rounded ? 1 : 0)
                    }
                }
            }

            Text {
                text: Strings.spacesRounded
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: card.rounded ? Strings.stateOn : Strings.stateOff
                color: card.rounded ? Theme.accent : Theme.fgSubtle
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.preferredWidth: 22
                text: "»"
                color: Theme.accent
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: Strings.spacesRounding
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            GlassButton {
                implicitWidth: 28
                implicitHeight: 28
                iconText: "−"
                label: ""
                onClicked: {
                    var v = card.rounding <= 0 ? 0 : Math.max(card.rounding - 1, 2)
                    card.rounding = v
                    if (v >= 2) setValue("rounding", v)
                }
            }

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 28
                radius: Theme.radiusSmall
                color: Theme.bgCard
                border.color: Theme.borderSubtle
                border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.margins: 2
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.fgText
                        font.pixelSize: Theme.scaledFont(11)
                        font.family: Theme.fontFamily
                        font.bold: true
                        text: card.rounding
                    }
            }

            GlassButton {
                implicitWidth: 28
                implicitHeight: 28
                iconText: "+"
                label: ""
                onClicked: {
                    var v = card.rounding < 2 ? 2 : Math.min(card.rounding + 1, 10)
                    card.rounding = v
                    setValue("rounding", v)
                }
            }
        }

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 36
            iconText: "\uf00c"
            label: Strings.btnApply
            active: true
            onClicked: if (!applyProc.running) applyProc.running = true
        }
    }
}
