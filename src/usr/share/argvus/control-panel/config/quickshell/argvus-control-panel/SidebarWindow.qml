import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool sidebarVisible: false
    readonly property string cardsConfigScript: Theme.systemConfig + "/control-panel/sh/cards-config.sh"
    property var cards: []
    property var allCards: []
    ListModel { id: cardsModel }
    property var cardDefinitions: ({
        "user": "UserCard.qml",
        "notifications": "NotificationCard.qml",
        "calendar": "CalendarCard.qml",
        "weather": "WeatherCard.qml",
        "volume": "VolumeCard.qml",
        "brightness": "BrightnessCard.qml",
        "network": "NetworkCard.qml",
        "bluetooth": "BluetoothCard.qml",
        "system": "SystemCard.qml",
        "appearance": "AppearanceCard.qml",
        "session": "SessionCard.qml",
        "display": "DisplayCard.qml",
        "spaces-borders-position": "SpacesBordersPositionCard.qml",
        "power": "PowerCard.qml"
    })

    // The helper is the sole owner of defaults, persisted preferences, and
    // normalization for future cards added by package updates.
    function loadCards() {
        if (!cardsStatusProcess.running)
            cardsStatusProcess.running = true
    }

    function persistMove(card, sceneY) {
        previewMove(card, sceneY)
        var sourceIndex = -1
        var targetIndex = allCards.length
        for (var j = 0; j < allCards.length; j++) {
            if (allCards[j].id === card.cardId) {
                sourceIndex = j
                break
            }
        }
        var visibleSourceIndex = cards.findIndex(function(entry) { return entry.id === card.cardId })
        if (visibleSourceIndex >= 0 && visibleSourceIndex + 1 < cards.length) {
            var nextId = cards[visibleSourceIndex + 1].id
            for (var nextIndex = 0; nextIndex < allCards.length; nextIndex++) {
                if (allCards[nextIndex].id === nextId) {
                    targetIndex = nextIndex
                    break
                }
            }
        }
        if (sourceIndex >= 0 && sourceIndex < targetIndex)
            targetIndex -= 1
        if (sourceIndex < 0 || sourceIndex === targetIndex)
            return

        var nextAllCards = allCards.slice()
        var movedAll = nextAllCards.splice(sourceIndex, 1)[0]
        nextAllCards.splice(targetIndex, 0, movedAll)
        allCards = nextAllCards

        if (cardsMoveProcess.running)
            cardsMoveProcess.running = false
        cardsMoveProcess.command = ["sh", cardsConfigScript, "move", card.cardId, String(targetIndex)]
        cardsMoveProcess.running = true
    }

    // Reorder the in-memory model while the pointer crosses card centers. The
    // layout animation then acts as a live insertion preview instead of waiting
    // for release, which also makes the valid drop location unambiguous.
    function previewMove(card, sceneY) {
        var sourceIndex = cards.findIndex(function(entry) { return entry.id === card.cardId })
        if (sourceIndex < 0)
            return
        var targetIndex = cards.length
        for (var i = 0; i < cards.length; i++) {
            if (i === sourceIndex)
                continue
            var loader = cardsRepeater.itemAt(i)
            if (loader && loader.item && loader.item.mapToItem(null, 0, loader.item.height / 2).y > sceneY) {
                targetIndex = i
                if (sourceIndex < targetIndex)
                    targetIndex -= 1
                break
            }
        }
        if (sourceIndex === targetIndex)
            return
        var nextCards = cards.slice()
        var moved = nextCards.splice(sourceIndex, 1)[0]
        nextCards.splice(targetIndex, 0, moved)
        cards = nextCards
        cardsModel.move(sourceIndex, targetIndex, 1)
    }

    Process {
        id: cardsStatusProcess
        command: ["sh", root.cardsConfigScript, "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(this.text)
                    // QML may expose JSON arrays as QJSValue objects rather
                    // than JavaScript Array instances. Check the indexed
                    // shape instead of using instanceof Array.
                    if (parsed && parsed.cards && typeof parsed.cards.length === "number") {
                        root.allCards = parsed.cards
                        var enabledCards = []
                        for (var index = 0; index < parsed.cards.length; index++) {
                            var card = parsed.cards[index]
                            if (!card || card.enabled !== true || root.cardDefinitions[card.id] === undefined)
                                continue
                            enabledCards.push({ id: card.id, source: root.cardDefinitions[card.id] })
                        }
                        root.cards = enabledCards
                        cardsModel.clear()
                        for (var enabledIndex = 0; enabledIndex < enabledCards.length; enabledIndex++)
                            cardsModel.append(enabledCards[enabledIndex])
                    }
                } catch (error) {
                    console.warn("Could not load Control Panel card preferences")
                }
            }
        }
    }

    Process { id: cardsMoveProcess }

    screen: Quickshell.screens[0]

    WlrLayershell.margins {
        top: Theme.sidebarMarginTop
        right: Theme.sidebarMarginRight
        bottom: Theme.sidebarMarginBottom
        left: 0
    }

    WlrLayershell.keyboardFocus: sidebarVisible
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        right: true
    }

    aboveWindows: true
    exclusiveZone: 0
    // A janela tem exatamente o tamanho da caixa — sem pixels extras
    // O blur do Hyprland age na área da janela, então não pode sobrar nada fora
    implicitWidth: sidebarVisible ? Theme.sidebarWidth : 0

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.effectsEnabled ? 70 : 0; easing.type: Easing.OutBounce }
    }

    color: "transparent"

    function publishControlPanelState() {
        // Set the command imperatively from the new value.  A binding in the
        // Process command can still contain the previous value while a
        // property-change handler is running.
        stateProc.command = ["bash", "-c",
            "state_dir=\"${XDG_CACHE_HOME:-$HOME/.cache}/argvus/waybar\"; mkdir -p \"$state_dir\"; state_file=\"$state_dir/control-panel-state\"; state_tmp=\"$state_file.$$\"; printf '%s\\n' \"$1\" > \"$state_tmp\" && mv -f \"$state_tmp\" \"$state_file\"",
            "argvus-control-panel-state",
            sidebarVisible ? "open" : "close"
        ]
        if (stateProc.running)
            stateProc.running = false
        stateProc.running = true
    }

    onSidebarVisibleChanged: {
        publishControlPanelState()
        if (sidebarVisible)
            keyCatcher.forceActiveFocus()
    }

    Component.onCompleted: publishControlPanelState()

    Process {
        id: stateProc
    }

    Item {
        id: panel
        // Janela = caixa: x:0, ocupa tudo
        x: 0
        y: 0
        width: root.width
        height: root.height

        // Fundo do painel (atrás do conteúdo)
        Rectangle {
            anchors.fill: parent
            color: Theme.bgPanel
            radius: Theme.radius
            z: 0
        }

        // Borda do painel (na frente do conteúdo — cobre o scroll nas bordas arredondadas)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Theme.borderSubtle
            border.width: 1
            radius: Theme.radius
            z: 2
        }

        // Captura Esc
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.sidebarVisible = false
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }

        // Flickable — mais confiável que ScrollView para calcular contentHeight
        Flickable {
            z: 1
            id: flick
            anchors {
                fill: parent
                rightMargin: 10   // espaço para a scrollbar
            }
            clip: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            flickDeceleration: 3000
            maximumFlickVelocity: 2000
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentCol
                width: flick.width
                spacing: 8

                Item { Layout.preferredHeight: 2 }

                Repeater {
                    id: cardsRepeater
                    model: cardsModel
                    delegate: Loader {
                        id: cardLoader
                        required property var modelData
                        source: modelData.source
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.preferredHeight: item ? item.implicitHeight : 0
                        Behavior on y {
                            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                        }

                        onLoaded: {
                            item.cardId = modelData.id
                            item.reorderEnabled = true
                            item.pollingActive = Qt.binding(function() { return root.sidebarVisible })
                        }

                        Connections {
                            target: cardLoader.item
                            function onReorderDropped(card, sceneY) {
                                root.persistMove(card, sceneY)
                            }
                            function onReorderMoved(card, sceneY) {
                                root.previewMove(card, sceneY)
                            }
                        }
                    }
                }

                AboutCard {
                    pollingActive: root.sidebarVisible
                    reorderEnabled: false
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                }

                Item { Layout.preferredHeight: 10 }
            }
        }

        // Scrollbar manual — track
        Rectangle {
            id: scrollTrack
            z: 1
            anchors {
                right: panel.right
                top: panel.top
                bottom: panel.bottom
                rightMargin: 3
                topMargin: 8
                bottomMargin: 8
            }
            width: 3
            radius: 2
            color: Theme.scrollbarBg
            visible: flick.contentHeight > flick.height

            // Thumb
            Rectangle {
                id: scrollThumb
                width: parent.width
                radius: 2

                height: Math.max(32,
                    scrollTrack.height * (flick.height / Math.max(flick.contentHeight, 1))
                )

                y: flick.contentHeight > flick.height
                    ? (scrollTrack.height - height)
                        * (flick.contentY / (flick.contentHeight - flick.height))
                    : 0

                color: thumbMa.pressed
                      ? Theme.scrollbarFg
                      : thumbMa.containsMouse
                          ? Qt.rgba(1, 1, 1, 0.75)
                          : Theme.scrollbarFg

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                MouseArea {
                    id: thumbMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeVerCursor

                    property real startY: 0
                    property real startContentY: 0

                    onPressed: function(mouse) {
                        startY        = mouse.y + scrollThumb.y
                        startContentY = flick.contentY
                    }
                    onPositionChanged: function(mouse) {
                        if (!pressed) return
                        var delta = (mouse.y + scrollThumb.y) - startY
                        var ratio = delta / (scrollTrack.height - scrollThumb.height)
                        flick.contentY = Math.max(0,
                            Math.min(startContentY + ratio * (flick.contentHeight - flick.height),
                                     flick.contentHeight - flick.height))
                    }
                }
            }
        }
    }
}
