import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleSession
    cardIcon:  ">"

    property int idleTimeout: 300
    property bool lockDpms: false
    property var idleOptions: [
        { seconds: 60,  label: "1m" },
        { seconds: 300, label: "5m" },
        { seconds: 600, label: "10m" },
        { seconds: 900, label: "15m" },
        { seconds: 1800, label: "30m" },
        { seconds: 0,   label: Strings.idleLockNever },
    ]

    function applyIdleTimeout(seconds) {
        if (idleSetProc.running) return
        idleSetProc.command = ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/idle-timeout.sh " + seconds]
        idleSetProc.running = true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: Strings.idleLockTitle
            color: Theme.fgText
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.letterSpacing: 1
        }

        // Timeout pills that wrap instead of being squeezed, so "Nunca/Never"
        // (a wider label) never overflows its box.
        Flow {
            Layout.fillWidth: true
            spacing: 5

            Repeater {
                model: idleOptions

                Rectangle {
                    required property var modelData

                    implicitWidth: pillText.implicitWidth + 20
                    implicitHeight: 28
                    radius: Theme.radiusPill
                    color: idleTimeout === modelData.seconds ? Theme.accentDim : Theme.bgPanel
                    border.width: 1
                    border.color: idleTimeout === modelData.seconds ? Theme.accent : Theme.borderSubtle

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        id: pillText
                        anchors.centerIn: parent
                        text: modelData.label
                        color: idleTimeout === modelData.seconds ? Theme.accent : (pillMa.containsMouse ? Theme.accent : Theme.fgSubtle)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: pillMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: applyIdleTimeout(modelData.seconds)
                    }
                }
            }
        }
    }

    Item { Layout.preferredHeight: 2 }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: lockDpmsToggleBtn
            width: 44; height: 24
            radius: Theme.radiusPill

            color: lockDpms ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                id: lockDpmsKnob
                width: 18; height: 18
                radius: Math.max(2, Theme.radiusPill / 2)
                x: lockDpms ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader

                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: lockDpmsToggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: lockDpmsToggleProc.running = true
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Strings.lockDpmsTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Text {
                text: lockDpms ? Strings.lockDpmsEnabled : Strings.lockDpmsDisabled
                color: lockDpms ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                opacity: 1
            }
        }

        Text {
            text: lockDpms ? "ON" : "OFF"
            color: lockDpms ? Theme.accent : Theme.danger
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
            if (!idleStatusProc.running) idleStatusProc.running = true
            if (!lockDpmsStatusProc.running) lockDpmsStatusProc.running = true
        }
    }

    Process {
        id: idleSetProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/idle-timeout.sh 300"]
        stdout: SplitParser {
            onRead: data => idleTimeout = Number(data.trim())
        }
    }

    Process {
        id: idleStatusProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/idle-timeout.sh status"]
        stdout: SplitParser {
            onRead: data => idleTimeout = Number(data.trim())
        }
    }

    Process {
        id: lockDpmsToggleProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/lock-dpms-toggle.sh toggle"]
        stdout: SplitParser {
            onRead: data => lockDpms = data.trim() === "enabled"
        }
    }

    Process {
        id: lockDpmsStatusProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/lock-dpms-toggle.sh status"]
        stdout: SplitParser {
            onRead: data => lockDpms = data.trim() === "enabled"
        }
    }
}
