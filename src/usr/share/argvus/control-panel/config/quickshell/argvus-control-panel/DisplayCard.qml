import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

BaseCard {
    id: card
    cardTitle: Strings.cardTitleDisplay
    cardIcon: "»"

    readonly property string script: "argvus displayctl"

    property var monitors: []
    property var nightLight: null
    property string nightError: ""

    function refreshNightLight() {
        if (!nightStatus.running && !nightToggle.running) nightStatus.running = true
    }

    Process {
        id: nightStatus
        command: ["argvus", "config", "display", "night-light", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { card.nightLight = JSON.parse(text) }
                catch (error) { card.nightLight = null }
            }
        }
        onExited: function(code) { if (code !== 0) card.nightLight = null }
    }

    Process {
        id: nightToggle
        command: ["argvus", "config", "display", "night-light", "toggle"]
        onExited: function(code) {
            card.nightError = code === 0 ? "" : Strings.displayNightFailed
            card.refreshNightLight()
        }
    }


    Timer {
        interval: 2000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: {
            card.refreshNightLight()
            if (!statusProc.running) statusProc.running = true
            if (!brightProbe.running) brightProbe.running = true
            if (card.brightSupported && !brightGet.running) brightGet.running = true
        }
    }

    // Read current monitor state (name/res/pos/scale/power) from hyprctl.
    Process {
        id: statusProc
        command: ["bash", "-c", card.script + " --status"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n")
                var current = null
                var list = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("=")
                    if (parts.length === 2) {
                        var key = parts[0]
                        var val = parts[1]
                        if (key === "name") {
                            current = { name: val, res: "", pos: "", scale: "", dpi: "", power: "" }
                            list.push(current)
                        } else if (current) {
                            current[key] = val
                        }
                    }
                }
                card.monitors = list
            }
        }
    }

    Process {
        id: setProc
        property string cmd: ""
        command: ["sh", "-c", cmd]
    }

    function setMonitor(monitor, key, value) {
        setProc.cmd = card.script + " --set " + monitor + " " + key + " " + value
        setProc.running = true
    }

    // ── Global brightness (backlight) reuse ──
    readonly property string brightScript: "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/sh/brightness-switch.sh"
    property bool brightSupported: false
    property real brightness: 0

    Process {
        id: brightProbe
        command: ["bash", "-c", card.brightScript + " --status"]
        stdout: SplitParser {
            onRead: data => {
                var backend = data.trim()
                card.brightSupported = (backend === "brightnessctl" || backend === "ddcutil")
            }
        }
    }
    Process {
        id: brightGet
        command: ["bash", "-c", card.brightScript + " --get"]
        stdout: SplitParser {
            onRead: data => {
                var pct = parseFloat(data.trim()) || 0
                card.brightness = Math.min(Math.max(pct / 100, 0), 1)
            }
        }
    }
    Process {
        id: brightSet
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    function setBrightness(v) {
        var pct = Math.round(v * 100)
        brightSet.cmd = card.brightScript + " --set " + pct
        brightSet.running = true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            visible: card.nightLight !== null && card.nightLight.available === true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: Strings.displayNightLight
                color: Theme.fgText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.scaledFont(11)
            }
            Text {
                visible: card.nightLight !== null && card.nightLight.active === true
                text: card.nightLight && card.nightLight.effective_temperature !== null
                    ? card.nightLight.effective_temperature + " K" : ""
                color: Theme.fgSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.scaledFont(11)
            }
            Rectangle {
                id: nightSwitch
                readonly property bool checked: card.nightLight !== null && card.nightLight.active === true
                enabled: !nightToggle.running && !nightStatus.running
                activeFocusOnTab: true
                Layout.alignment: Qt.AlignVCenter
                Accessible.role: Accessible.CheckBox
                Accessible.name: Strings.displayNightLight
                Accessible.checkable: true
                Accessible.checked: checked
                width: 44
                height: 24
                radius: Theme.radius
                color: checked ? Theme.accent : Theme.borderSubtle
                border.width: 0
                opacity: enabled ? 1 : 0.55

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (!nightToggle.running) nightToggle.running = true
                        event.accepted = true
                    }
                }

                Rectangle {
                    width: 18
                    height: 18
                    radius: Math.max(2, Theme.radius)
                    x: nightSwitch.checked ? parent.width - width - 3 : 3
                    y: (parent.height - height) / 2
                    color: Theme.bgHeader
                    Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        nightSwitch.forceActiveFocus()
                        if (!nightToggle.running) nightToggle.running = true
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            visible: card.nightError.length > 0
            text: card.nightError
            color: Theme.danger
            font.family: Theme.fontFamily
            font.pixelSize: Theme.scaledFont(11)
            wrapMode: Text.WordWrap
        }

        // Global brightness (backlight for panel/internal)
        RowLayout {
            Layout.fillWidth: true
            visible: card.brightSupported
            spacing: 6
            Text {
                text: Strings.displayBrightness
                color: Theme.fgText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.scaledFont(11)
                Layout.alignment: Qt.AlignVCenter
            }
            Slider {
                id: brightSlider
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                from: 0
                to: 1
                value: card.brightness
                onMoved: card.setBrightness(value)
            }
            Text {
                text: Math.round(card.brightness * 100) + "%"
                color: Theme.fgText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.scaledFont(11)
                Layout.preferredWidth: 32
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Repeater {
            model: card.monitors
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Monitor name + resolution
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: modelData.name
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(12)
                        font.weight: Font.Bold
                    }
                    Text {
                        text: modelData.res
                        color: Theme.fgDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: modelData.power === "off" ? "\uf06e" : "\uf070"
                        color: modelData.power === "off" ? Theme.danger : Theme.fgSubtle
                        font.family: Theme.fontIcon
                        font.pixelSize: Theme.scaledFont(13)
                    }
                }

                // Scale slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: Strings.displayScale
                        color: Theme.fgText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Slider {
                        id: scaleSlider
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        from: 0.5
                        to: 3.0
                        stepSize: 0.25
                        snapMode: Slider.SnapOnRelease
                        value: modelData.scale
                        onMoved: setMonitor(modelData.name, "scale", value)
                    }
                    Text {
                        text: modelData.scale
                        color: Theme.fgText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                        Layout.preferredWidth: 30
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // DPI slider (text/UI scaling per monitor)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: Strings.displayDpi
                        color: Theme.fgText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Slider {
                        id: dpiSlider
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        from: 32
                        to: 300
                        stepSize: 4
                        snapMode: Slider.SnapOnRelease
                        value: modelData.dpi || 96
                        onMoved: setMonitor(modelData.name, "dpi", value)
                    }
                    Text {
                        text: modelData.dpi || 96
                        color: Theme.fgText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(11)
                        Layout.preferredWidth: 30
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Power toggle
                GlassButton {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    iconText: modelData.power === "off" ? "\uf06e" : "\uf070"
                    label: modelData.power === "off" ? Strings.displayPowerOn : Strings.displayPowerOff
                    active: false
                    onClicked: setMonitor(modelData.name, "power",
                        modelData.power === "off" ? "on" : "off")
                }
            }
        }

        // Open the Displays page in argvus-control-center.
        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 36
            iconText: "\uf013"
            label: Strings.displayOpenCenter
            active: true
            onClicked: if (!ccDisplayProc.running) ccDisplayProc.running = true
        }
    }

    Process {
        id: ccDisplayProc
        command: ["argvus", "--displays"]
    }
}
