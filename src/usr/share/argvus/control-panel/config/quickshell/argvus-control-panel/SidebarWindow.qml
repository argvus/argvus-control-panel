import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool sidebarVisible: false
    property bool rightToLeft: false
    screen: Quickshell.screens[0]

    // Quickshell defaults this to the shell directory name, which the compositor
    // layer rules cannot rely on. Pin it so argvus-hyprland can target the
    // sidebar when it opts the surface into blur.
    WlrLayershell.namespace: "argvus-control-panel"

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
        NumberAnimation { duration: Theme.animationsEnabled ? 70 : 0; easing.type: Easing.OutBounce }
    }

    color: "transparent"

    function publishControlPanelState() {
        // Set the command imperatively from the new value.  A binding in the
        // Process command can still contain the previous value while a
        // property-change handler is running.
        stateProc.command = ["bash", "-c",
            "state_dir=\"${XDG_CACHE_HOME:-$HOME/.cache}/argvus/taskbar\"; mkdir -p \"$state_dir\"; state_file=\"$state_dir/control-panel-state\"; state_tmp=\"$state_file.$$\"; printf '%s\\n' \"$1\" > \"$state_tmp\" && mv -f \"$state_tmp\" \"$state_file\"",
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
            content.focusContent()
    }

    Component.onCompleted: publishControlPanelState()

    Process {
        id: stateProc
    }

    PanelContent {
        id: content
        anchors.fill: parent
        sidebarVisible: root.sidebarVisible
        rightToLeft: root.rightToLeft
        onCloseRequested: root.sidebarVisible = false
    }
}
