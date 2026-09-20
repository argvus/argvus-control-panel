import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string cardTitle: ""
    property string cardIcon:  ""
    property bool pollingActive: true
    property string cardId: ""
    property bool reorderEnabled: false
    property bool reorderDragging: false

    // The sidebar owns persistence because it knows the complete card order.
    // Cards only report a drop from their dedicated header handle.
    signal reorderDropped(var card, real sceneY)
    signal reorderMoved(var card, real sceneY)

    implicitHeight: innerCol.implicitHeight + 24
    radius: Theme.radius

    // Glassmorphism: fundo escuro semi-transparente
    // O blur do Hyprland age na layer toda — este alpha cria o efeito "vidro fosco"
    color: Theme.bgHeader

    border.color: root.reorderDragging ? Theme.accent : Theme.accentMid
    border.width: 1
    opacity: root.reorderDragging ? 0.78 : 1.0
    scale: root.reorderDragging ? 0.985 : 1.0

    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

    // (removed top accent line — visual was duplicated across cards)

    ColumnLayout {
        id: innerCol
        anchors {
            fill: parent
            topMargin: 12; bottomMargin: 12
            leftMargin: 14; rightMargin: 14
        }
        spacing: 8

        // card header
        RowLayout {
            spacing: 6

            Text {
                text: "\uf054"
                font.family: Theme.fontIcon
                font.pixelSize: Theme.scaledFont(11)
                font.weight: Font.Black
                color: Theme.accent
                opacity: 0.9
            }

            Text {
                text: root.cardTitle
                color: Theme.accentLight          // teal um pouco mais claro para realçar
                font.pixelSize: Theme.scaledFont(11)
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                font.family: Theme.fontFamily
            }

            Item { Layout.fillWidth: true }

            Item {
                visible: root.reorderEnabled
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: reorderHandle.containsMouse ? Theme.accentLight : Theme.fgSubtle
                    font.family: Theme.fontIcon
                    font.pixelSize: Theme.scaledFont(15)
                }

                MouseArea {
                    id: reorderHandle
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    acceptedButtons: Qt.LeftButton
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    property real lastSceneY: 0

                    // Keep the drag gesture on the handle.  Flickable would
                    // otherwise steal the pointer grab before the release,
                    // making a reorder appear to do nothing.
                    onPressed: function(mouse) {
                        root.reorderDragging = true
                        lastSceneY = reorderHandle.mapToItem(null, mouse.x, mouse.y).y
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            lastSceneY = reorderHandle.mapToItem(null, mouse.x, mouse.y).y
                            root.reorderMoved(root, lastSceneY)
                        }
                    }
                    onReleased: function(mouse) {
                        lastSceneY = reorderHandle.mapToItem(null, mouse.x, mouse.y).y
                        root.reorderDragging = false
                        root.reorderDropped(root, lastSceneY)
                    }
                    onCanceled: {
                        root.reorderDragging = false
                    }
                }
            }
        }

        // divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.accent
            opacity: 0.18
        }

        // body content
        ColumnLayout {
            id: contentCol
            Layout.fillWidth: true
            spacing: 6
        }
    }

    default property alias content: contentCol.data
}
