import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleNotifications
    cardIcon:  "»"

    property var notifications: []
    property int historyCount: 0
    property real clockOffset: 0
    property var expandedGroups: ({})
    property var expandedItems: ({})
    property var removalQueue: []
    property bool dndEnabled: false
    property bool dndAvailable: false
    property bool dndBusy: false
    property string dndError: ""

    readonly property var groups: {
        var result = []
        for (var i = 0; i < notifications.length; i++) {
            var item = notifications[i]
            var group = result.find(function(g) { return g.app === item.app })
            if (!group) {
                group = {app: item.app, items: []}
                result.push(group)
            }
            group.items.push(item)
        }
        return result
    }

    function toggleExpanded(key, isGroup) {
        var state = Object.assign({}, isGroup ? expandedGroups : expandedItems)
        state[key] = !state[key]
        if (isGroup) expandedGroups = state
        else expandedItems = state
    }

    function removeGroup(items) {
        if (removeProc.running || removalQueue.length) return
        removalQueue = items.filter(function(item) { return item.id !== null }).map(function(item) { return item.id })
        removeNext()
    }

    function removeNext() {
        if (!removalQueue.length) {
            historyProc.running = true
            return
        }
        var id = removalQueue[0]
        removalQueue = removalQueue.slice(1)
        removeProc.command = ["dunstctl", "history-rm", String(id)]
        removeProc.running = true
    }

    Process {
        id: clockProc
        command: ["cat", "/proc/uptime"]
        running: pollingActive
        stdout: StdioCollector {
            onStreamFinished: {
                var uptime = Number(this.text.trim().split(" ")[0])
                if (Number.isFinite(uptime)) clockOffset = Date.now() - uptime * 1000
            }
        }
    }

    Process {
        id: removeProc
        onExited: function(code) {
            if (code !== 0) {
                removalQueue = []
                dndError = Strings.notifChangeFailed
                historyProc.running = true
            } else removeNext()
        }
    }

    Timer {
        interval: 3000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (dndAvailable && !historyProc.running) historyProc.running = true
    }

    Timer {
        interval: 2000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: if (!dndStatusProc.running && !dndToggleProc.running) dndStatusProc.running = true
    }

    Process {
        id: dndStatusProc
        command: ["argvus", "notifications", "dnd", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var value = this.text.trim()
                if (value.indexOf("dnd=true") === 0) {
                    dndAvailable = true
                    dndEnabled = true
                    if (!historyProc.running) historyProc.running = true
                    dndError = ""
                } else if (value.indexOf("dnd=false") === 0) {
                    dndAvailable = true
                    dndEnabled = false
                    dndError = ""
                    if (!historyProc.running) historyProc.running = true
                } else {
                    dndAvailable = false
                    dndError = Strings.notifReadFailed
                }
            }
        }
    }

    Process {
        id: dndToggleProc
        command: ["argvus", "notifications", "dnd", "toggle"]
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

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            Text {
                text: Strings.notifDnd
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(14)
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap
            }

            Text {
                text: dndAvailable ? (dndEnabled ? Strings.notifDndOn : Strings.notifDndOff) : Strings.notifUnavailable
                color: dndAvailable ? (dndEnabled ? Theme.danger : Theme.accent) : Theme.fgSubtle
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap
            }
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
                    dndEnabled = !dndEnabled
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
                    for (var i = 0; i < entries.length; i++) {
                        var n = entries[i]
                        items.push({
                            id: n.id ? n.id.data : null,
                            icon: n.icon_path ? n.icon_path.data : "",
                            timestamp: n.timestamp ? Number(n.timestamp.data) : 0,
                            app:     n.appname  ? n.appname.data  : Strings.notifAppUnknown,
                            summary: n.summary  ? n.summary.data  : "",
                            body:    n.body     ? n.body.data     : ""
                        })
                    }
                    items.sort(function(a, b) { return b.timestamp - a.timestamp })
                    if (JSON.stringify(items) !== JSON.stringify(notifications)) notifications = items
                    historyCount   = items.length
                } catch(e) {
                    notifications = []
                    historyCount   = 0
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
                historyCount   = 0
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Item { Layout.fillWidth: true }
        GlassButton {
            visible: historyCount > 0
            implicitWidth: 70
            label: Strings.notifClear
            iconText: ""
            enabled: !removeProc.running && removalQueue.length === 0
            onClicked: clearProc.running = true
        }
    }

    Repeater {
        model: groups
        delegate: ColumnLayout {
            id: groupDelegate
            required property var modelData
            readonly property bool expanded: expandedGroups[modelData.app] === true
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Image {
                    source: groupDelegate.modelData.items[0].icon
                    visible: status === Image.Ready
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    sourceSize.width: 20
                    sourceSize.height: 20
                    fillMode: Image.PreserveAspectFit
                }
                Button {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: (groupDelegate.expanded ? "▾ " : "▸ ") + groupDelegate.modelData.app
                    Accessible.name: groupDelegate.modelData.app
                    onClicked: toggleExpanded(groupDelegate.modelData.app, true)
                    contentItem: Text {
                        text: parent.text
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(13)
                        elide: Text.ElideRight
                    }
                    background: Rectangle {
                        color: parent.visualFocus || parent.hovered ? Theme.accentDim : "transparent"
                        radius: Theme.radius
                    }
                }
                Text {
                    visible: clockOffset > 0 && groupDelegate.modelData.items[0].timestamp > 0
                    text: visible ? Qt.formatTime(new Date(clockOffset + groupDelegate.modelData.items[0].timestamp / 1000), Qt.DefaultLocaleShortDate) : ""
                    color: Theme.fgSubtle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.scaledFont(11)
                }
                Button {
                    id: dismissGroup
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    padding: 4
                    enabled: !removeProc.running && removalQueue.length === 0
                    Accessible.name: Strings.notifClear + " · " + groupDelegate.modelData.app
                    ToolTip.visible: hovered || visualFocus
                    ToolTip.text: Accessible.name
                    onClicked: removeGroup(groupDelegate.modelData.items)
                    contentItem: Text {
                        text: ""
                        font.family: Theme.fontIcon
                        font.pixelSize: Theme.scaledFont(14)
                        color: dismissGroup.hovered || dismissGroup.visualFocus ? Theme.danger : Theme.fgSubtle
                        opacity: dismissGroup.enabled ? 1 : 0.4
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: Theme.radius
                        color: dismissGroup.hovered || dismissGroup.visualFocus ? Theme.accentDim : "transparent"
                        border.width: dismissGroup.visualFocus ? 1 : 0
                        border.color: Theme.accent
                    }
                }
            }

            Repeater {
                model: groupDelegate.expanded ? groupDelegate.modelData.items : []
                delegate: ColumnLayout {
                    id: entry
                    required property var modelData
                    readonly property bool expanded: groupDelegate.expanded && expandedItems[String(modelData.id)] === true
                    Layout.fillWidth: true
                    spacing: 2
                    Button {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: entry.modelData.summary || entry.modelData.app
                        onClicked: {
                            if (!groupDelegate.expanded) toggleExpanded(groupDelegate.modelData.app, true)
                            toggleExpanded(String(entry.modelData.id), false)
                        }
                        contentItem: Text {
                            text: parent.text
                            textFormat: Text.PlainText
                            color: Theme.fgText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.scaledFont(13)
                            wrapMode: Text.Wrap
                            maximumLineCount: entry.expanded ? 2147483647 : 1
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            color: parent.visualFocus || parent.hovered ? Theme.accentDim : "transparent"
                            radius: Theme.radius
                        }
                    }
                    TextEdit {
                        id: bodyDocument
                        visible: false
                        readOnly: true
                        textFormat: TextEdit.RichText
                        text: entry.modelData.body.replace(/<img\b[^>]*>/gi, "")
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        text: bodyDocument.getText(0, bodyDocument.length)
                        textFormat: Text.PlainText
                        visible: entry.expanded && text !== ""
                        color: Theme.fgSubtle
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.scaledFont(12)
                        wrapMode: Text.Wrap
                        maximumLineCount: entry.expanded ? 2147483647 : 2
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Text {
        visible: notifications.length === 0
        text: Strings.notifNone
        color: Theme.fgSubtle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.scaledFont(13)
        Layout.fillWidth: true
    }
}
