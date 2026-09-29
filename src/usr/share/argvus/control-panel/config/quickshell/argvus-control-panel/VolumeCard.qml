import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleVolume
    cardIcon:  "»"

    property real volume: Theme.audioVolume
    property bool muted:  Theme.audioMuted
    property bool dragging: false
    property bool applyAfterSet: false

    Connections {
        target: Theme
        function onAudioVolumeChanged() { if (!dragging) volume = Theme.audioVolume }
        function onAudioMutedChanged() { muted = Theme.audioMuted }
    }

    Timer {
        interval: 1000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!dragging && !readProc.running) readProc.running = true
    }

    Process {
        id: readProc
        command: ["bash", "-c",
            "argvus-config get /audio --effective 2>/dev/null | jq -c . || wpctl get-volume @DEFAULT_AUDIO_SINK@"
        ]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var canonical = JSON.parse(data)
                    if (canonical && typeof canonical.output_volume === "number") {
                        volume = Math.min(Math.max(canonical.output_volume / 100.0, 0), 1.0)
                        muted = canonical.output_muted === true
                        return
                    }
                } catch (error) {}
                var parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    volume = Math.min(parseFloat(parts[1]) || 0, 1.0)
                    muted = data.includes("[MUTED]")
                }
            }
        }
    }

    Process {
        id: setProc
        property string cmd: ""
        command: ["bash", "-c", cmd]
        onExited: {
            Theme.reloadCanonicalConfig()
            if (applyAfterSet && !dragging) {
                applyAfterSet = false
                if (!applyConfigProc.running) applyConfigProc.running = true
            }
        }
    }

    Process {
        id: applyConfigProc
        command: ["systemctl", "--user", "reload", "argvus-config.service"]
    }

    function setVolume(v) {
        volume = Math.min(Math.max(v, 0), 1.0)
        Theme.audioVolume = volume
        setProc.cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + volume.toFixed(2) +
            " && argvus-config set /audio/output_volume " + Math.round(volume * 100)
        setProc.running = true
    }

    function toggleMute() {
        muted = !muted
        Theme.audioMuted = muted
        setProc.cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && argvus-config set /audio/output_muted " + (muted ? "true" : "false") +
            " && systemctl --user reload argvus-config.service"
        setProc.running = true
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
                    applyAfterSet = true
                    if (!setProc.running) {
                        applyAfterSet = false
                        if (!applyConfigProc.running) applyConfigProc.running = true
                    }
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
