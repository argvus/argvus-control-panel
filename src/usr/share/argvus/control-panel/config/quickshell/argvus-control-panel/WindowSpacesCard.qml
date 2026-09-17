import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    id: card
    cardTitle: Strings.cardTitleWindowSpaces
    cardIcon: "»"

    property int gapsIn: 3
    property int gapsOut: 1

    readonly property string script: "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/hyprland/sh/spaces-switch.sh"
    readonly property string reloadScript: "argvus-sessionctl reload"
    readonly property var controls: [
        { key: "gaps_in", label: Strings.spacesGapIn, valueProp: "gapsIn" },
        { key: "gaps_out", label: Strings.spacesGapOut, valueProp: "gapsOut" }
    ]

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
                    if (parts[0] === "gaps_in") card.gapsIn = parseInt(parts[1])
                    if (parts[0] === "gaps_out") card.gapsOut = parseInt(parts[1])
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
        setProc.cmd = card.script + " --set " + key + " " + Math.round(value)
        setProc.running = true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: controls
            delegate: RowLayout {
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
                    text: modelData.label
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
                        var v = Math.max(card[modelData.valueProp] - 1, 0)
                        card[modelData.valueProp] = v
                        setValue(modelData.key, v)
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
                        text: card[modelData.valueProp]
                    }
                }

                GlassButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    iconText: "+"
                    label: ""
                    onClicked: {
                        var v = Math.min(card[modelData.valueProp] + 1, 100)
                        card[modelData.valueProp] = v
                        setValue(modelData.key, v)
                    }
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
