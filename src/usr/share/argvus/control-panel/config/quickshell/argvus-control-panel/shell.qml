import QtQuick
import Quickshell
import Quickshell.Io
import org.argvus.i18n 1.0

ShellRoot {
    id: root
    readonly property string catalogRoot: "/usr/share/argvus/i18n"
    property string selectedLocale: "en-US"
    property bool pendingExclusiveOpen: false
    property int pendingPopupClosures: 0

    function openExclusive() {
        if (sidebarWin.sidebarVisible || pendingExclusiveOpen)
            return
        pendingExclusiveOpen = true
        pendingPopupClosures = 3
        closeFocusProcess.running = true
        closeClockProcess.running = true
        closeCalendarProcess.running = true
    }

    function finishPopupClose() {
        pendingPopupClosures -= 1
        if (pendingPopupClosures <= 0 && pendingExclusiveOpen) {
            pendingExclusiveOpen = false
            sidebarWin.sidebarVisible = true
        }
    }

    function closeExclusive() {
        pendingExclusiveOpen = false
        pendingPopupClosures = 0
        sidebarWin.sidebarVisible = false
    }

    function loadCatalog(localeName, contents) {
        if (!contents || contents.trim() === "")
            return
        try {
            var loaded = JSON.parse(contents)
            var next = Object.assign({}, I18n.catalogs)
            next[localeName + "/control-panel"] = loaded
            I18n.catalogs = next
            I18n.locale = selectedLocale
        } catch (e) {
            // The central I18n singleton returns the key when a catalog is invalid.
        }
    }

    Process {
        id: localeProcess
        command: ["argvus", "i18n", "locale"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var detected = this.text.trim()
                root.selectedLocale = detected !== "" ? detected : "en-US"
                I18n.locale = root.selectedLocale
            }
        }
    }

    FileView {
        id: selectedCatalog
        path: root.catalogRoot + "/" + root.selectedLocale + "/control-panel.json"
        onTextChanged: root.loadCatalog(root.selectedLocale, text())
    }

    FileView {
        id: fallbackCatalog
        path: root.catalogRoot + "/en-US/control-panel.json"
        onTextChanged: root.loadCatalog("en-US", text())
    }

    Process {
        id: closeFocusProcess
        command: ["gapplication", "action", "sh.argvus.Focus", "close"]
        onExited: function(code) { root.finishPopupClose() }
    }

    Process {
        id: closeClockProcess
        command: ["gapplication", "action", "sh.argvus.Clock", "close"]
        onExited: function(code) { root.finishPopupClose() }
    }

    Process {
        id: closeCalendarProcess
        command: ["argvus", "taskbar-calendar", "hide"]
        onExited: function(code) { root.finishPopupClose() }
    }

    // Toggle via: qs -c argvus-control-panel ipc call sidebar toggle
    IpcHandler {
        target: "theme"
        function reload(): void { Theme.reloadTheme() }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void {
            if (sidebarWin.sidebarVisible || root.pendingExclusiveOpen)
                root.closeExclusive()
            else
                root.openExclusive()
        }
        function open(): void { root.openExclusive() }
        function close(): void { root.closeExclusive() }
    }

    SidebarWindow {
        id: sidebarWin
    }
}
