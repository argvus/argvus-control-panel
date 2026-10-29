import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string iconText: ""
    property string label: ""
    property bool   active: false
    property bool   vertical: false
    property color  accentColor: Theme.accent
    signal clicked()

    activeFocusOnTab: true

    implicitHeight: 38
    radius: Theme.radiusSmall

    color: {
        if (active) return Theme.bgCard
        if (ma.containsMouse) return Theme.accentDim
        return Theme.bgPanel
    }
    border.color: {
        if (active) return accentColor
        if (activeFocus) return Theme.accentLight
        if (ma.containsMouse) return accentColor
        return Theme.borderSubtle
    }
    border.width: activeFocus ? 2 : 1

    Keys.onPressed: function(event) {
        if (!root.enabled || (event.key !== Qt.Key_Return
                && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Space))
            return
        root.clicked()
        event.accepted = true
    }

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        anchors.centerIn: parent
        spacing: 5
        visible: !root.vertical

        Text {
            visible: iconText !== ""
            text: iconText
            color: active || ma.containsMouse ? accentColor : Theme.fgSubtle
            font.family: Theme.fontIcon
            font.pixelSize: Theme.scaledFont(15)
            font.weight: Font.Black
        }

        Text {
            visible: label !== ""
            text: label
            color: active ? accentColor : (ma.containsMouse ? accentColor : Theme.fgSubtle)
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.weight: active ? Font.Medium : Font.Normal
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        visible: root.vertical

        Text {
            visible: iconText !== ""
            text: iconText
            color: active || ma.containsMouse ? accentColor : Theme.fgSubtle
            font.family: Theme.fontIcon
            font.pixelSize: Theme.scaledFont(15)
            font.weight: Font.Black
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            visible: label !== ""
            text: label
            color: active ? accentColor : (ma.containsMouse ? accentColor : Theme.fgSubtle)
            font.pixelSize: Theme.scaledFont(11)
            font.family: Theme.fontFamily
            font.weight: active ? Font.Medium : Font.Normal
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus()
        onClicked: root.clicked()
    }
}
