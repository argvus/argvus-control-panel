import QtQuick
import Quickshell.Io
import org.argvus.i18n 1.0

PanelContent {
    id: root
    embedded: true
    rightToLeft: selectedLocale === "ar" || selectedLocale === "ur-PK"
    property string selectedLocale: "en-US"
    readonly property string catalogRoot: "/usr/share/argvus/i18n"

    function reloadTheme(): void { Theme.reloadTheme() }
    function reloadCards(): void { root.loadCards() }

    function loadCatalog(localeName, contents) {
        if (!contents || contents.trim() === "") return
        try {
            const next = Object.assign({}, I18n.catalogs)
            next[localeName + "/control-panel"] = JSON.parse(contents)
            I18n.catalogs = next
            I18n.locale = selectedLocale
        } catch (error) {
            console.warn("Cannot load Control Panel translations:", error)
        }
    }

    Process {
        command: ["argvus", "i18n", "locale"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.selectedLocale = this.text.trim() || "en-US"
                I18n.locale = root.selectedLocale
            }
        }
    }
    FileView {
        path: root.catalogRoot + "/" + root.selectedLocale + "/control-panel.json"
        onTextChanged: root.loadCatalog(root.selectedLocale, text())
    }
    FileView {
        path: root.catalogRoot + "/en-US/control-panel.json"
        onTextChanged: root.loadCatalog("en-US", text())
    }
}
