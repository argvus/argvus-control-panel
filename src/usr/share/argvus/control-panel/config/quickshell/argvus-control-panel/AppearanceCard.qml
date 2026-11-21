import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleAppearance
    cardIcon:  "»"

    // Both switches show the saved state from Theme. While a toggle command is
    // running they show the requested state instead; if the command fails the
    // card falls back to the saved state on its own.
    property bool telemetryRequested: false
    property bool animationsRequested: false
    property bool effectsRequested: false
    property bool accentPending: false
    readonly property bool widgetTelemetryEnabled: toggleProc.running ? telemetryRequested : Theme.widgetTelemetrySurfaceActive
    // ANIMATIONS is the master switch for motion; EFFECTS is the master switch for
    // blur and transparency. They are independent, as `argvus effects-toggle
    // animations|effects` are.
    readonly property bool animationsOn: animationsToggleProc.running ? animationsRequested : Theme.animationsState !== "disabled"
    readonly property bool effectsOn: effectsToggleProc.running ? effectsRequested : Theme.effectsEnabled

    // Changing the `effects` section makes argvus-config restart this panel,
    // which would kill a child process half way. Run the command as a transient
    // user unit instead (the same reason themeProc does) and wait for it.
    function detachedCommand(words) {
        return ["systemd-run", "--user", "--wait", "--collect", "--quiet",
            "--setenv=ARGVUS_CONFIG_HOME=" + Theme.configHome,
            "--setenv=ARGVUS_SYSTEM_CONFIG=" + Theme.systemConfig, "--"].concat(words)
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: "\uf03e"
            label: Strings.btnWallpaper
            onClicked: wallpaperProc.running = true
        }

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: ""
            label: Strings.btnTheme
            onClicked: themeProc.running = true
        }
    }

    Item { Layout.preferredHeight: 4 }

    GlassButton {
        Layout.fillWidth: true
        implicitHeight: 44
        iconText: ""
        label: Strings.btnAccent
        accentColor: Theme.accent
        enabled: !accentPending
        onClicked: {
            if (accentPending) return
            accentPending = true
            accentProc.running = true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: widgetTelemetryToggleBtn
            width: 44; height: 24
            radius: Theme.radius

            color: widgetTelemetryEnabled ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                id: widgetTelemetryKnob
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: widgetTelemetryEnabled ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader

                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: widgetTelemetryToggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (toggleProc.running) return
                    telemetryRequested = !widgetTelemetryEnabled
                    toggleProc.running = true
                }
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 0
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: Strings.widgetTelemetryTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: widgetTelemetryEnabled ? Strings.widgetTelemetryEnabled : Strings.widgetTelemetryDisabled
                color: widgetTelemetryEnabled ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                opacity: 1
            }
        }

    }

    Item { Layout.preferredHeight: 2 }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: animationsToggleBtn
            width: 44; height: 24
            radius: Theme.radius
            color: animationsOn ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: animationsOn ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (animationsToggleProc.running) return
                    animationsRequested = !animationsOn
                    animationsToggleProc.running = true
                }
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 0
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: Strings.animationsTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: animationsOn ? Strings.animationsEnabled : Strings.animationsDisabled
                color: animationsOn ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: effectsToggleBtn
            width: 44; height: 24
            radius: Theme.radius
            color: effectsOn ? Theme.accent : Theme.borderSubtle
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                width: 18; height: 18
                radius: Math.max(2, Theme.radius)
                x: effectsOn ? parent.width - width - 3 : 3
                y: (parent.height - height) / 2
                color: Theme.bgHeader
                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (effectsToggleProc.running) return
                    effectsRequested = !effectsOn
                    effectsToggleProc.running = true
                }
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 0
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: Strings.effectsTitle
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }
            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                wrapMode: Text.Wrap

                text: effectsOn ? Strings.effectsEnabled : Strings.effectsDisabled
                color: effectsOn ? Theme.accent : Theme.danger
                font.pixelSize: Theme.scaledFont(13)
                font.family: Theme.fontFamily
            }
        }
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "sh ${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/sh/hypr-wallpaper-pick.sh"]
    }

    Process {
        id: themeProc
        // The theme menu and the switch run outside this panel's service cgroup,
        // so a panel restart (a layout change) cannot end them. The switch calls
        // `ipc call theme reload` when the new theme is active.
        command: ["systemd-run", "--user", "--collect", "--quiet",
            "--setenv=ARGVUS_CONFIG_HOME=" + Theme.configHome,
            "--setenv=ARGVUS_SYSTEM_CONFIG=" + Theme.systemConfig,
            "--", "argvus", "theme-switch"]
        onExited: {
            Theme.reloadActiveTheme()
            Theme.reloadAccent()
        }
    }

    Process {
        id: accentProc
        command: detachedCommand(["argvus", "config", "accent"])
        onExited: {
            accentPending = false
            Theme.reloadAccent()
        }
    }

    Process {
        id: toggleProc
        command: detachedCommand(["argvus", "widget-telemetry-toggle", "toggle"])
        onExited: Theme.refresh()
    }

    Process {
        id: animationsToggleProc
        command: detachedCommand(["argvus", "effects-toggle", "animations", "toggle"])
        onExited: Theme.refresh()
    }

    Process {
        id: effectsToggleProc
        command: detachedCommand(["argvus", "effects-toggle", "effects", "toggle"])
        onExited: Theme.refresh()
    }
}
