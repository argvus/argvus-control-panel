import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    id: card
    cardTitle: Strings.cardTitleSpacesBordersPosition
    cardIcon: "»"

    property string appliedPos: "top"
    property string selectedPos: "top"
    property bool dirty: false

    property int taskbarTop: 0
    property int taskbarLeft: 0
    property int taskbarRight: 0
    property int taskbarBottom: 0
    property int gapsIn: 1
    property int gapsOutTop: 1
    property int gapsOutLeft: 1
    property int gapsOutRight: 1
    property int gapsOutBottom: 1
    property bool rounded: false
    property int rounding: 0

    readonly property string spacesScript: "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/hyprland/sh/spaces-switch.sh"
    readonly property string bordersScript: "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/hyprland/sh/borders-switch.sh"
    readonly property string reloadScript: "argvus-sessionctl reload"
    readonly property var taskbarControls: [
        { key: "waybar_top", label: Strings.spacesTaskbarTop, valueProp: "taskbarTop" },
        { key: "waybar_left", label: Strings.spacesTaskbarLeft, valueProp: "taskbarLeft" },
        { key: "waybar_right", label: Strings.spacesTaskbarRight, valueProp: "taskbarRight" },
        { key: "waybar_bottom", label: Strings.spacesTaskbarBottom, valueProp: "taskbarBottom" }
    ]
    readonly property var windowControls: [
        { key: "gaps_in", label: Strings.spacesGapIn, valueProp: "gapsIn" },
        { key: "gaps_out_top", label: Strings.spacesGapOutTop, valueProp: "gapsOutTop" },
        { key: "gaps_out_left", label: Strings.spacesGapOutLeft, valueProp: "gapsOutLeft" },
        { key: "gaps_out_right", label: Strings.spacesGapOutRight, valueProp: "gapsOutRight" },
        { key: "gaps_out_bottom", label: Strings.spacesGapOutBottom, valueProp: "gapsOutBottom" }
    ]

    Timer {
        interval: 2000
        running: pollingActive
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!spacesStatusProc.running) spacesStatusProc.running = true
            if (!bordersStatusProc.running) bordersStatusProc.running = true
        }
    }

    Process {
        id: spacesStatusProc
        command: ["bash", "-c", card.spacesScript + " --status"]
        stdout: SplitParser {
            onRead: data => {
                if (card.dirty) return
                var lines = data.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("=")
                    if (parts.length !== 2) continue
                    if (parts[0] === "waybar_pos") {
                        card.appliedPos = parts[1]
                        card.selectedPos = parts[1]
                    }
                    for (var j = 0; j < taskbarControls.length; j++) {
                        if (taskbarControls[j].key === parts[0]) {
                            card[taskbarControls[j].valueProp] = parseInt(parts[1])
                            break
                        }
                    }
                    for (var k = 0; k < windowControls.length; k++) {
                        if (windowControls[k].key === parts[0]) {
                            card[windowControls[k].valueProp] = parseInt(parts[1])
                            break
                        }
                    }
                }
            }
        }
    }

    Process {
        id: bordersStatusProc
        command: ["bash", "-c", card.bordersScript + " --status"]
        stdout: SplitParser {
            onRead: data => {
                if (card.dirty) return
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
        id: applyProc
        command: ["true"]
        onExited: card.dirty = false
    }

    function adjustValue(valueProp, delta, minimum, maximum) {
        card[valueProp] = Math.max(minimum, Math.min(maximum, card[valueProp] + delta))
        card.dirty = true
    }

    function applyChanges() {
        if (applyProc.running) return
        var commands = [
            card.spacesScript + " --set-persist waybar_pos " + card.selectedPos,
            card.spacesScript + " --set-persist waybar_top " + card.taskbarTop,
            card.spacesScript + " --set-persist waybar_left " + card.taskbarLeft,
            card.spacesScript + " --set-persist waybar_right " + card.taskbarRight,
            card.spacesScript + " --set-persist waybar_bottom " + card.taskbarBottom,
            card.spacesScript + " --set-persist gaps_in " + card.gapsIn,
            card.spacesScript + " --set-persist gaps_out_top " + card.gapsOutTop,
            card.spacesScript + " --set-persist gaps_out_left " + card.gapsOutLeft,
            card.spacesScript + " --set-persist gaps_out_right " + card.gapsOutRight,
            card.spacesScript + " --set-persist gaps_out_bottom " + card.gapsOutBottom,
            card.bordersScript + " --set rounded " + (card.rounded ? 1 : 0)
        ]
        if (card.rounded) commands.push(card.bordersScript + " --set rounding " + card.rounding)
        applyProc.command = ["sh", "-c", commands.join(" && ") + " && " + card.reloadScript]
        applyProc.running = true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: Strings.taskbarPositionLabel
            color: Theme.accent
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { value: "top", label: Strings.taskbarTop, icon: "\uf077" },
                    { value: "bottom", label: Strings.taskbarBottom, icon: "\uf078" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: Theme.radiusSmall
                    color: positionArea.containsMouse ? Theme.accentDim : Theme.bgPanel
                    border.color: card.selectedPos === modelData.value ? Theme.accent : Theme.borderSubtle
                    border.width: card.selectedPos === modelData.value ? 2 : 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            border.color: card.selectedPos === modelData.value ? Theme.accent : Theme.fgSubtle
                            border.width: 2
                            color: "transparent"
                            Rectangle {
                                anchors.centerIn: parent
                                width: 6; height: 6; radius: 3
                                color: card.selectedPos === modelData.value ? Theme.accent : "transparent"
                            }
                        }
                        Text {
                            text: modelData.icon
                            color: card.selectedPos === modelData.value ? Theme.accent : Theme.fgSubtle
                            font.family: Theme.fontIcon
                            font.pixelSize: Theme.scaledFont(14)
                            font.weight: Font.Black
                        }
                        Text {
                            text: modelData.label
                            color: card.selectedPos === modelData.value ? Theme.accent : Theme.fgText
                            font.pixelSize: Theme.scaledFont(11)
                            font.family: Theme.fontFamily
                            font.weight: card.selectedPos === modelData.value ? Font.Medium : Font.Normal
                        }
                    }

                    MouseArea {
                        id: positionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            card.selectedPos = modelData.value
                            card.dirty = true
                        }
                    }
                }
            }
        }

        Text {
            text: Strings.taskbarSpacesTitle
            color: Theme.accent
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.bold: true
        }

        Repeater {
            model: taskbarControls
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 6
                Text { text: modelData.label; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily }
                Item { Layout.fillWidth: true }
                GlassButton {
                    implicitWidth: 28; implicitHeight: 28
                    iconText: "−"; label: ""
                    onClicked: card.adjustValue(modelData.valueProp, -1, 0, 100)
                }
                Rectangle {
                    Layout.preferredWidth: 48; Layout.preferredHeight: 28
                    radius: Theme.radiusSmall; color: Theme.bgCard; border.color: Theme.borderSubtle; border.width: 1
                    Text { anchors.fill: parent; anchors.margins: 2; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily; font.bold: true; text: card[modelData.valueProp] }
                }
                GlassButton {
                    implicitWidth: 28; implicitHeight: 28
                    iconText: "+"; label: ""
                    onClicked: card.adjustValue(modelData.valueProp, 1, 0, 100)
                }
            }
        }

        Text {
            text: Strings.windowSpacesTitle
            color: Theme.accent
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.bold: true
        }

        Repeater {
            model: windowControls
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 6
                Text { text: modelData.label; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily }
                Item { Layout.fillWidth: true }
                GlassButton {
                    implicitWidth: 28; implicitHeight: 28
                    iconText: "−"; label: ""
                    onClicked: card.adjustValue(modelData.valueProp, -1, 0, 100)
                }
                Rectangle {
                    Layout.preferredWidth: 48; Layout.preferredHeight: 28
                    radius: Theme.radiusSmall; color: Theme.bgCard; border.color: Theme.borderSubtle; border.width: 1
                    Text { anchors.fill: parent; anchors.margins: 2; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily; font.bold: true; text: card[modelData.valueProp] }
                }
                GlassButton {
                    implicitWidth: 28; implicitHeight: 28
                    iconText: "+"; label: ""
                    onClicked: card.adjustValue(modelData.valueProp, 1, 0, 100)
                }
            }
        }

        Text {
            text: Strings.generalBordersTitle
            color: Theme.accent
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Rectangle {
                width: 44; height: 24; radius: Theme.radius
                color: card.rounded ? Theme.accent : Theme.borderSubtle
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                    width: 18; height: 18; radius: Math.max(2, Theme.radius)
                    x: card.rounded ? parent.width - width - 3 : 3
                    y: (parent.height - height) / 2
                    color: Theme.bgHeader
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        card.rounded = !card.rounded
                        if (card.rounded && card.rounding < 2) card.rounding = 2
                        card.dirty = true
                    }
                }
            }
            Text { text: Strings.spacesRounded; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily }
            Text { text: card.rounded ? Strings.stateOn : Strings.stateOff; color: card.rounded ? Theme.accent : Theme.fgSubtle; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: Strings.spacesRounding; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily }
            Item { Layout.fillWidth: true }
            GlassButton {
                implicitWidth: 28; implicitHeight: 28
                enabled: card.rounded
                opacity: card.rounded ? 1 : 0.4
                iconText: "−"; label: ""
                onClicked: card.adjustValue("rounding", -1, 2, 10)
            }
            Rectangle {
                Layout.preferredWidth: 48; Layout.preferredHeight: 28
                radius: Theme.radiusSmall; color: Theme.bgCard; border.color: Theme.borderSubtle; border.width: 1
                Text { anchors.fill: parent; anchors.margins: 2; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: Theme.fgText; font.pixelSize: Theme.scaledFont(11); font.family: Theme.fontFamily; font.bold: true; text: card.rounding }
            }
            GlassButton {
                implicitWidth: 28; implicitHeight: 28
                enabled: card.rounded
                opacity: card.rounded ? 1 : 0.4
                iconText: "+"; label: ""
                onClicked: card.adjustValue("rounding", 1, 2, 10)
            }
        }

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 36
            iconText: "\uf00c"
            label: Strings.btnApply
            active: true
            onClicked: card.applyChanges()
        }
    }
}
