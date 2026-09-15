import QtQuick
import Quickshell
import Quickshell.Io
import org.argvus.i18n 1.0

ShellRoot {
    id: root
    readonly property string catalogRoot: "/usr/share/argvus/i18n"
    property string selectedLocale: "en-US"

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
        command: ["argvus-i18n", "locale"]
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
    // Toggle via: qs -c argvus-control-panel ipc call sidebar toggle
    IpcHandler {
        target: "sidebar"
        function toggle(): void { sidebarWin.sidebarVisible = !sidebarWin.sidebarVisible }
        function open():   void { sidebarWin.sidebarVisible = true }
        function close():  void { sidebarWin.sidebarVisible = false }
    }

    SidebarWindow {
        id: sidebarWin
    }
}
