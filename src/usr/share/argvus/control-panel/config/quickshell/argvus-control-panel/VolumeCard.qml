import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleVolume
    cardIcon:  "»"

    property real volume: 0
    property bool muted: false
    property bool dragging: false
    // Latest slider value (percent) not yet sent; -1 when nothing is waiting.
    property int pendingPercent: -1

    // PipeWire is the live source of truth. The taskbar scroll and the media
    // keys change it directly, so this card reads the sink instead of the
    // preference saved in `argvus config`, which only follows after a change.
    function refresh() {
        if (dragging || setProc.running || muteProc.running || pendingPercent >= 0 || readProc.running)
            return
        readProc.running = true
    }

    Timer {
        interval: 2000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: refresh()
    }

    // `pactl subscribe` prints one line per audio event, so a change made
    // elsewhere shows up right away. The timer above is only a safety net.
    Process {
        id: eventProc
        command: ["env", "LC_ALL=C", "pactl", "subscribe"]
        running: pollingActive
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf(" on sink ") !== -1 || data.indexOf(" on server") !== -1)
                    settleTimer.restart()
            }
        }
    }

    // One volume change emits several events; read once after they settle.
    Timer {
        id: settleTimer
        interval: 60
        onTriggered: refresh()
    }

    Process {
        id: readProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            // Output looks like "Volume: 0.45" or "Volume: 0.45 [MUTED]".
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                if (parts.length < 2 || parts[0] !== "Volume:") return
                var level = parseFloat(parts[1])
                if (isNaN(level)) return
                volume = Math.min(Math.max(level, 0), 1.0)
                muted = data.indexOf("[MUTED]") !== -1
            }
        }
    }

    // `argvus config audio` sets the sink and records the result in
    // /audio, so a later `config project` does not restore an old volume.
    Process {
        id: setProc
        onExited: {
            if (pendingPercent >= 0) sendVolume()
            else refresh()
        }
    }

    Process {
        id: muteProc
        command: ["argvus", "config", "audio", "mute", "toggle"]
        onExited: refresh()
    }

    // Sends the latest value only; while the previous command runs, newer
    // slider positions overwrite pendingPercent instead of queueing.
    function sendVolume() {
        if (setProc.running || pendingPercent < 0) return
        setProc.command = ["argvus", "config", "audio", "volume", String(pendingPercent)]
        pendingPercent = -1
        setProc.running = true
    }

    function setVolume(v) {
        volume = Math.min(Math.max(v, 0), 1.0)
        pendingPercent = Math.round(volume * 100)
        sendVolume()
    }

    function toggleMute() {
        if (muteProc.running) return
        muted = !muted
        muteProc.running = true
    }

    // ── Mute button + slider + value ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        GlassButton {
            implicitHeight: 32
            implicitWidth: 32
            iconText: {
                if (muted) return ""
                if (volume > 0.6) return ""
                if (volume > 0.2) return ""
                return ""
            }
            label: ""
            active: !muted
            accentColor: muted ? Theme.danger : Theme.accent
            onClicked: toggleMute()
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 32

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4; radius: 2
                color: Theme.borderSubtle

                Rectangle {
                    width: track.width * (muted ? 0 : volume)
                    height: 4; radius: 2
                    color: muted ? Theme.dangerDim : Theme.accent
                    Behavior on width { NumberAnimation { duration: Theme.animFast } }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    dragging = true
                    setVolume(mouse.x / width)
                }
                onPositionChanged: function(mouse) {
                    if (pressed) setVolume(mouse.x / width)
                }
                onReleased: {
                    dragging = false
                    refresh()
                }
            }
        }

        Text {
            text: muted ? Strings.volumeMuted : Math.round(volume * 100) + "%"
            color: muted ? Theme.danger : Theme.fgDim
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            Layout.preferredWidth: 32
            horizontalAlignment: Text.AlignRight
        }
    }

    // ── Step buttons ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: [
                { label: "-10", delta: -0.10 },
                { label: "-5",  delta: -0.05 },
                { label: "+5",  delta:  0.05 },
                { label: "+10", delta:  0.10 },
            ]
            delegate: GlassButton {
                Layout.fillWidth: true
                implicitHeight: 22
                iconText: ""
                label: modelData.label
                active: false
                radius: 3
                onClicked: setVolume(volume + modelData.delta)
            }
        }
    }
}
