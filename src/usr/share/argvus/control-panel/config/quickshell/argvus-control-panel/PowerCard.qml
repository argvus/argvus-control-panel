import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitlePower
    cardIcon:  "»"

    property string activeProfile: "balanced"

    readonly property var profiles: Strings.profiles

    // The profile can also change through `powerprofilesctl` or another
    // frontend, so the visible card keeps reading it instead of once.
    Timer {
        interval: 3000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!readProc.running && !setProc.running) readProc.running = true
    }

    Process {
        id: readProc
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                var l = data.trim()
                if (l.length > 0) activeProfile = l
            }
        }
    }

    Process {
        id: setProc
        property string nextProfile: ""
        command: ["powerprofilesctl", "set", nextProfile]
        onExited: function(code) {
            if (code === 0) activeProfile = nextProfile
        }
    }

    function setProfile(id) {
        setProc.nextProfile = id
        setProc.running = true
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: profiles
            delegate: GlassButton {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 1
                implicitHeight: Math.max(52, Theme.scaledFont(15) + Theme.scaledFont(11) + 24)
                vertical: true
                iconText: modelData.icon
                label: modelData.label
                tooltipText: modelData.desc
                active: activeProfile === modelData.id
                onClicked: setProfile(modelData.id)
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        wrapMode: Text.Wrap
        text: {
            var icon = "\uf0e7"
            switch(activeProfile) {
            case "power-saver":  return icon + "  " + Strings.powerSaverActive
            case "performance":  return icon + "  " + Strings.powerPerfActive
            default:             return icon + "  " + Strings.powerBalancedActive
            }
        }
        color: Theme.accent
        font.pixelSize: Theme.scaledFont(16)
        font.family: Theme.fontFamily
        opacity: 1
        horizontalAlignment: Text.AlignHCenter
    }
}
