import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool sidebarVisible: false

    screen: Quickshell.screens[0]

    WlrLayershell.margins {
        top: Theme.marginTop
        right: Theme.waybarMarginRight
        bottom: Theme.marginBottom
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

    onSidebarVisibleChanged: {
        stateProc.running = true
        if (sidebarVisible)
            keyCatcher.forceActiveFocus()
    }

    Component.onCompleted: stateProc.running = true

    Process {
        id: stateProc
        command: ["bash", "-c",
            root.sidebarVisible
                ? "mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/argvus/waybar && echo open > ${XDG_CACHE_HOME:-$HOME/.cache}/argvus/waybar/sidebar-state"
                : "mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/argvus/waybar && echo close > ${XDG_CACHE_HOME:-$HOME/.cache}/argvus/waybar/sidebar-state"
        ]
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

                UserCard          { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                NotificationCard  { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                CalendarCard      { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                WeatherCard       { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                VolumeCard        { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                BrightnessCard    { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                NetworkCard       { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                BluetoothCard     { id: bluetoothCard; visible: bluetoothCard.available; pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                SystemCard        { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                KeyboardCard      { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                AppearanceCard    { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                SessionCard       { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                DisplayCard       { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                TaskbarCard       { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                SpacesCard        { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                SettingsCard      { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                PowerCard         { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }
                AboutCard         { pollingActive: root.sidebarVisible; Layout.fillWidth: true; Layout.leftMargin: 10; Layout.rightMargin: 10 }

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
