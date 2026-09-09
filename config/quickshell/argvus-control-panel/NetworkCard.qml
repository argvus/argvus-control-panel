import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleNetwork
    cardIcon:  "»"

    property string iface:     "—"
    property string ip:        "—"
    property string downSpeed: "0 B/s"
    property string upSpeed:   "0 B/s"
    property string ssid:      ""
    property bool   connected: false
    property bool   networkingEnabled: true

    property var _prevRx: ({})
    property var _prevTx: ({})

    // ── Check network state via argvus-network ──
    Timer {
        interval: 5000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!nmStateProc.running) nmStateProc.running = true
    }

    Process {
        id: nmStateProc
        command: ["argvus-networkctl", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                lines.forEach(function(line) {
                    if (line.indexOf("networking=") === 0)
                        networkingEnabled = line.trim().slice("networking=".length) === "enabled"
                })
            }
        }
    }

    Process {
        id: toggleNetProc
        property bool turnOn: true
        command: ["argvus-networkctl", turnOn ? "enable" : "disable"]
        onExited: {
            if (exitCode === 0) {
                networkingEnabled = turnOn
                netProc.running = true
            }
        }
    }

    // ── Network stats ──
    Timer {
        interval: 5000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!netProc.running) netProc.running = true
    }

    Process {
        id: netProc
        command: ["argvus-networkctl", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var obj = {}
                lines.forEach(function(line) {
                    var idx = line.indexOf("=")
                    if (idx >= 0) obj[line.slice(0, idx)] = line.slice(idx + 1)
                })

                networkingEnabled = obj.networking === "enabled"
                if (!obj.iface || obj.iface === "" || obj.connected !== "yes") {
                    connected = false; return
                }

                iface     = obj.iface
                ip        = obj.ip ? obj.ip : "—"
                ssid      = obj.ssid || ""
                connected = obj.connected === "yes"

                var now = Date.now()
                var rx  = parseFloat(obj.rx) || 0
                var tx  = parseFloat(obj.tx) || 0

                var prevRx = _prevRx[iface] || null
                var prevTx = _prevTx[iface] || null
                var prevTs = _prevRx["_ts"]  || null

                if (prevRx !== null && prevTs !== null) {
                    var dt = (now - prevTs) / 1000
                    if (dt > 0) {
                        downSpeed = fmtSpeed((rx - prevRx) / dt)
                        upSpeed   = fmtSpeed((tx - prevTx) / dt)
                    }
                }

                _prevRx = { [iface]: rx, _ts: now }
                _prevTx = { [iface]: tx }
            }
        }
    }

    function fmtSpeed(bps) {
        if (bps < 0)        bps = 0
        if (bps < 1024)     return Math.round(bps) + " B/s"
        if (bps < 1048576)  return (bps / 1024).toFixed(1) + " KB/s"
        return (bps / 1048576).toFixed(1) + " MB/s"
    }

    // ── Network toggle ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: toggleBtn
            width: 44; height: 24
            radius: Theme.radius

            color: networkingEnabled ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                id: toggleKnob
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: networkingEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader

                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: toggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toggleNetProc.turnOn = !networkingEnabled
                    toggleNetProc.running = true
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Strings.netTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Text {
                text: {
                    if (!networkingEnabled) return Strings.netDisabled
                    if (connected) return ssid !== "" ? ssid : Strings.netConnected
                    return Strings.netNoConnection
                }
                color: {
                    if (!networkingEnabled) return Theme.danger
                    if (connected) return Theme.accent
                    return Theme.danger
                }
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                opacity: 1
            }
        }

        Text {
            text: networkingEnabled ? "ON" : "OFF"
            color: networkingEnabled ? Theme.accent : Theme.danger
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            font.weight: Font.Bold
            font.letterSpacing: 2
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // ── IP ──
    RowLayout {
        Layout.fillWidth: true
        visible: connected && networkingEnabled
        spacing: 4

        Text {
            text: "\uf0ac"
            color: Theme.accent
            font.family: "Font Awesome 7 Free"
            font.pixelSize: Theme.scaledFont(16)
            font.weight: Font.Black
            opacity: 1
        }
        Text {
            text: ip
            color: Theme.fgText
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            Layout.fillWidth: true
        }
        Text {
            text: iface
            color: Theme.accent
            font.pixelSize: Theme.scaledFont(13)
            font.family: Theme.fontFamily
            opacity: 1
        }
    }

    // ── Speed ↓ / ↑ ──
    RowLayout {
        Layout.fillWidth: true
        visible: connected && networkingEnabled
        spacing: 12

        RowLayout {
            spacing: 4
            Text { text: "↓"; color: Theme.fgText; font.pixelSize: Theme.scaledFont(13); font.family: Theme.fontFamily }
            Text {
                text: downSpeed
                color: Theme.fgText; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
                Layout.preferredWidth: 80
            }
        }

        RowLayout {
            spacing: 4
            Text { text: "↑"; color: Theme.fgText; font.pixelSize: Theme.scaledFont(13); font.family: Theme.fontFamily }
            Text {
                text: upSpeed
                color: Theme.fgText; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
            }
        }
    }
}
