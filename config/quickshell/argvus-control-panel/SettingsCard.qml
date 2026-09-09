import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleSettings
    cardIcon:  "»"

    Process {
        id: settingsProc
        command: ["argvus", "--control-center"]
    }

    Text {
        Layout.fillWidth: true
        text: Strings.settingsHint
        color: Theme.fgDim
        font.pixelSize: Theme.scaledFont(10)
        font.family: Theme.fontFamily
        wrapMode: Text.WordWrap
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: [
                { label: Strings.settingsFonts, icon: "\uf031" },
                { label: Strings.settingsApps,  icon: "\uf2d0" }
            ]

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: modelData.icon
                    color: Theme.accent
                    font.family: Theme.fontIcon
                    font.pixelSize: Theme.scaledFont(13)
                    font.weight: Font.Black
                    Layout.preferredWidth: 20
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData.label
                    color: Theme.fgText
                    font.pixelSize: Theme.scaledFont(11)
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                }
            }
        }
    }

    GlassButton {
        Layout.fillWidth: true
        implicitHeight: 36
        iconText: "\uf013"
        label: Strings.settingsOpen
        active: true
        onClicked: if (!settingsProc.running) settingsProc.running = true
    }
}
