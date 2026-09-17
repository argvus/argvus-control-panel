import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleNotifications
    cardIcon:  "»"

    property var notifications: []
    property int unreadCount: 0
    property int currentPage: 0
    property bool dndEnabled: false
    property bool dndAvailable: false
    property bool dndBusy: false
    property string dndError: ""

    readonly property int pageSize: 3
    readonly property int pageCount: Math.ceil(notifications.length / pageSize)
    readonly property var pageNotifications: notifications.slice(currentPage * pageSize, (currentPage + 1) * pageSize)

    onNotificationsChanged: currentPage = 0

    Timer {
        interval: 3000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!historyProc.running) historyProc.running = true
    }

    Timer {
        interval: 2000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!dndStatusProc.running && !dndToggleProc.running) dndStatusProc.running = true
    }

    Process {
        id: dndStatusProc
        command: ["argvus-notifications", "dnd", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var value = this.text.trim()
                if (value.indexOf("dnd=true") === 0) {
                    dndAvailable = true
                    dndEnabled = true
                    dndError = ""
                } else if (value.indexOf("dnd=false") === 0) {
                    dndAvailable = true
                    dndEnabled = false
                    dndError = ""
                } else {
                    dndAvailable = false
                    dndError = Strings.notifReadFailed
                }
            }
        }
    }

    Process {
        id: dndToggleProc
        command: ["argvus-notifications", "dnd", "toggle"]
        onStarted: dndBusy = true
        onExited: {
            dndBusy = false
            if (exitCode === 0) dndStatusProc.running = true
            else {
                dndAvailable = false
                dndError = Strings.notifChangeFailed
            }
        }

    }

    // Master notification switch. Its state is always refreshed from Dunst.
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: Strings.notifDnd
            color: Theme.fgText
            font.pixelSize: Theme.scaledFont(14)
            font.family: Theme.fontFamily
            Layout.fillWidth: true
        }

        Text {
            text: dndAvailable ? (dndEnabled ? Strings.notifDndOn : Strings.notifDndOff) : Strings.notifUnavailable
            color: dndAvailable ? (dndEnabled ? Theme.danger : Theme.accent) : Theme.fgSubtle
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
        }

        Rectangle {
            width: 44; height: 24; radius: Theme.radius
            color: dndEnabled ? Theme.danger : Theme.borderSubtle
            opacity: dndBusy || !dndAvailable ? 0.55 : 1
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                width: 18; height: 18; radius: Math.max(2, Theme.radius)
                x: dndEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
            }

            MouseArea {
                anchors.fill: parent
                enabled: dndAvailable && !dndBusy
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    dndToggleProc.running = true
                }
            }
        }
    }

    Text {
        visible: dndError !== ""
        text: dndError
        color: Theme.danger
        font.pixelSize: Theme.scaledFont(10)
        font.family: Theme.fontFamily
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }

    Process {
        id: historyProc
        command: ["dunstctl", "history"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text)
                    var items = []
                    var entries = data.data[0] || []
                    for (var i = 0; i < entries.length && i < 9; i++) {
                        var n = entries[i]
                        items.push({
                            app:     n.appname  ? n.appname.data  : Strings.notifAppUnknown,
                            summary: n.summary  ? n.summary.data  : "",
                            body:    n.body     ? n.body.data     : ""
                        })
                    }
                    notifications = items
                    unreadCount   = items.length
                } catch(e) {
                    notifications = []
                    unreadCount   = 0
                }
            }
        }
    }

    Process {
        id: clearProc
        command: ["dunstctl", "history-clear"]
        onExited: function(code) {
            if (code === 0) {
                notifications = []
                unreadCount   = 0
            }
        }
    }

    // Header: count + nav + clear button
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: unreadCount > 0 ? unreadCount + " " + Strings.notifRecent : Strings.notifNone
            color: Theme.fgText
            font.pixelSize: Theme.scaledFont(16)
            font.family: Theme.fontFamily
            Layout.fillWidth: true
        }

        RowLayout {
            visible: pageCount > 1
            spacing: 2

            NavBtn {
                text: "\uf053"
                enabled: currentPage > 0
                onClicked: currentPage--
            }

            Text {
                text: (currentPage + 1) + "/" + pageCount
                color: Theme.accent
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 28
            }

            NavBtn {
                text: "\uf054"
                enabled: currentPage < pageCount - 1
                onClicked: currentPage++
            }
        }

        GlassButton {
            visible: unreadCount > 0
            implicitWidth: 70
            implicitHeight: 22
            iconText: ""
            label: Strings.notifClear
            active: false
            radius: 3
            onClicked: clearProc.running = true
        }
    }

    // List of notifications (current page)
    Repeater {
        model: pageNotifications
        delegate: Rectangle {
            Layout.fillWidth: true
            implicitHeight: notifCol.implicitHeight + 12
            radius: 4
            color: Theme.bgPanel
            border.color: Theme.borderSubtle
            border.width: 1

            ColumnLayout {
                id: notifCol
                anchors { fill: parent; margins: 8 }
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "\uf192"
                        font.family: Theme.fontIcon
                        font.pixelSize: Theme.scaledFont(16)
                        font.weight: Font.Black
                        color: Theme.accent
                        opacity: 1
                    }
                    Text {
                        text: modelData.app
                        color: Theme.accent
                        font.pixelSize: Theme.scaledFont(13)
                        font.family: Theme.fontFamily
                        opacity: 1
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData.summary
                    color: Theme.fgText
                    font.pixelSize: Theme.scaledFont(16)
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                    wrapMode: Text.WordWrap
                    visible: modelData.summary !== ""
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData.body
                    color: Theme.fgText
                    font.pixelSize: Theme.scaledFont(13)
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                    visible: modelData.body !== ""
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }

    // Empty state
    RowLayout {
        visible: notifications.length === 0
        Layout.fillWidth: true
        spacing: 0
        Text {
            text: Strings.notifNone
            font.pixelSize: Theme.scaledFont(13)
            font.family: Theme.fontFamily
            color: Theme.fgSubtle
        }
    }

    component NavBtn: Rectangle {
        property string text: ""
        signal clicked()

        width: 22; height: 22; radius: 4
        color: ma.containsMouse ? Theme.accentDim : "transparent"
        border.color: ma.containsMouse ? Theme.accent : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.enabled ? (ma.containsMouse ? Theme.accent : Theme.fgSubtle) : Theme.borderSubtle
            font.family: Theme.fontIcon
            font.pixelSize: Theme.scaledFont(16)
            font.weight: Font.Black
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
