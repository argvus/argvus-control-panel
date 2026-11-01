import QtQuick
import QtQuick.Layouts
import QtCore
import Quickshell.Io

BaseCard {
    id: root
    cardTitle: Strings.cardTitleWeather
    cardIcon:  "»"

    property string location: ""
    property string cityName:    "—"
    property string condition:   "—"
    property string tempC:       "—"
    property string feelsLike:   "—"
    property string humidity:    "—"
    property string windKmh:     "—"
    property string weatherIcon: "~"
    property var forecastDays: []
    property int selectedTab: 0
    property bool   loading:     true
    property bool   hasError:    false
    property bool   hasData:     false
    property bool   refreshPending: false

    function iconForCode(value) {
        var code = parseInt(value)
        if (code === 0 || code === 113) return "\uf185"
        if (code <= 3 || code === 116 || code === 119 || code === 122) return ""
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82) || (code >= 176 && code <= 308)) return ""
        if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86) || (code >= 311 && code <= 377)) return ""
        if ((code >= 95 && code <= 99) || (code >= 386 && code <= 395)) return ""
        return ""
    }

    function dayLabel(dateValue) {
        var parts = dateValue.split("-")
        if (parts.length !== 3) return dateValue
        var date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]))
        return Qt.locale().standaloneDayName(date.getDay(), Locale.ShortFormat)
    }

    function refreshWeather() {
        if (fetchProc.running) {
            refreshPending = true
            return
        }
        refreshPending = false
        fetchProc.running = true
    }

    FileView {
        id: locationFile
        path: StandardPaths.writableLocation(StandardPaths.HomeLocation) +
              "/.config/argvus/data/.weather-location"
        // Absent until the user picks a location; the default is used meanwhile.
        printErrors: false
        onTextChanged: {
            var newLocation = text().trim()
            if (newLocation === root.location) return
            root.location = newLocation
            root.refreshWeather()
        }
    }

    // Atualiza a cada 15 minutos e sempre que a sidebar abre. A localização é
    // relida junto, porque ela também é alterada fora do painel.
    Timer {
        interval: 900000; running: pollingActive; repeat: true; triggeredOnStart: true
        onTriggered: {
            locationFile.reload()
            root.refreshWeather()
        }
    }

    Timer {
        id: deferredRefresh
        interval: 1
        repeat: false
        onTriggered: root.refreshWeather()
    }

    Process {
        id: fetchProc
        property string url: root.location !== ""
            ? "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1"
            : "https://wttr.in/?format=j1"
        command: ["sh", "-c", "\"${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/control-panel/sh/weather-fetch.sh\" \"$1\"", "argvus-weather", root.location]
        onStarted: { if (!hasData) loading = true; hasError = false }
        stdout: StdioCollector {
            onStreamFinished: {
                loading = false
                try {
                    var d    = JSON.parse(this.text)
                    var cur  = d.current_condition[0]
                    var area = d.nearest_area[0]

                    cityName  = area.areaName[0].value + ", " + area.country[0].value
                    tempC     = cur.temp_C
                    feelsLike = cur.FeelsLikeC
                    humidity  = cur.humidity
                    windKmh   = cur.windspeedKmph
                    condition = cur.weatherDesc[0].value
                    forecastDays = d.forecast || []

                    weatherIcon = iconForCode(cur.weatherCode)

                    hasData = true
                    hasError = false
                } catch(e) {
                    if (!hasData) hasError = true
                }
            }
        }
        onExited: function(code) {
            loading = false
            if (code !== 0 && !hasData) hasError = true
            if (root.refreshPending) {
                root.refreshPending = false
                deferredRefresh.restart()
            }
        }
    }

    Process {
        id: configureProc
        command: ["sh", "-c", "${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/control-panel/sh/weather-location.sh"]
        onExited: {
            locationFile.reload()
            root.refreshWeather()
        }
    }

    // Estado: loading
    Text {
        visible: loading
        Layout.fillWidth: true
        text: Strings.weatherLoading
        color: Theme.accent; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
        opacity: 1; horizontalAlignment: Text.AlignHCenter
    }

    // Estado: erro
    Text {
        visible: !loading && hasError
        Layout.fillWidth: true
        text: Strings.weatherError
        color: Theme.danger; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            radius: Theme.radiusSmall
            color: root.selectedTab === 0 ? Theme.bgCard : Theme.bgPanel
            border.color: root.selectedTab === 0 ? Theme.accent : Theme.borderSubtle
            Text {
                anchors.centerIn: parent
                text: qsTr("Now")
                color: root.selectedTab === 0 ? Theme.accent : Theme.fgSubtle
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedTab = 0 }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            radius: Theme.radiusSmall
            color: root.selectedTab === 1 ? Theme.bgCard : Theme.bgPanel
            border.color: root.selectedTab === 1 ? Theme.accent : Theme.borderSubtle
            Text {
                anchors.centerIn: parent
                text: qsTr("Week")
                color: root.selectedTab === 1 ? Theme.accent : Theme.fgSubtle
                font.pixelSize: Theme.scaledFont(11)
                font.family: Theme.fontFamily
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedTab = 1 }
        }
    }

    // Current conditions stay compact; the weekly forecast is shown on demand.
    ColumnLayout {
        visible: !loading && !hasError && root.selectedTab === 0
        Layout.fillWidth: true
        spacing: 6

        // Cidade
        Text {
            text: cityName
            color: Theme.fgDim; font.pixelSize: Theme.scaledFont(13); font.family: Theme.fontFamily
            Layout.fillWidth: true; elide: Text.ElideRight
            opacity: 1
        }

        // Icon + temperature
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: weatherIcon
                font.family: Theme.fontIcon
                font.weight: Font.Black
                color: Theme.fgText
                font.pixelSize: Theme.scaledFont(30)
            }

            ColumnLayout {
                spacing: 1
                Text {
                    text: tempC + "°C"
                    color: Theme.fgSubtle
                    font.pixelSize: Theme.scaledFont(26)
                    font.weight: Font.Light
                    font.family: Theme.fontFamily
                }
                Text {
                    text: condition
                    color: Theme.fgText
                    font.pixelSize: Theme.scaledFont(13)
                    font.family: Theme.fontFamily
                    opacity: 1
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true; height: 1
            color: Theme.accent; opacity: 0.10
        }

        // Details: feels like, humidity, wind
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 14; rowSpacing: 8

            Repeater {
                model: [
                    { label: Strings.weatherFeelsLike, value: feelsLike + "°C" },
                    { label: Strings.weatherHumidity,  value: humidity  + "%"  },
                    { label: Strings.weatherWind,      value: windKmh   + " km/h" },
                ]
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: modelData.label
                        color: Theme.accent; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
                        opacity: 1; Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: modelData.value
                        color: Theme.fgText; font.pixelSize: Theme.scaledFont(16); font.family: Theme.fontFamily
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

    }

    ColumnLayout {
        visible: !loading && !hasError && root.selectedTab === 1
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: forecastDays
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Text {
                    Layout.preferredWidth: 20
                    text: root.iconForCode(modelData.weatherCode)
                    color: Theme.fgText
                    font.family: Theme.fontIcon
                    font.pixelSize: Theme.scaledFont(14)
                }
                Text {
                    Layout.preferredWidth: 48
                    text: root.dayLabel(modelData.date)
                    color: Theme.fgDim
                    font.pixelSize: Theme.scaledFont(12)
                    font.family: Theme.fontFamily
                }
                Item { Layout.fillWidth: true }
                Text {
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignRight
                    text: modelData.minC + "°"
                    color: Theme.fgDim
                    font.pixelSize: Theme.scaledFont(12)
                    font.family: Theme.fontFamily
                }
                Text {
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignRight
                    text: modelData.maxC + "°C"
                    color: Theme.fgText
                    font.pixelSize: Theme.scaledFont(12)
                    font.family: Theme.fontFamily
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Item { Layout.fillWidth: true }

        GlassButton {
            implicitWidth: 100
            implicitHeight: 30
            iconText: ""
            label: Strings.weatherConfigure
            active: false
            onClicked: {
                if (!configureProc.running) configureProc.running = true
            }
        }

        GlassButton {
            implicitWidth: 92
            implicitHeight: 30
            iconText: "󰑓"
            label: Strings.weatherRefresh
            active: false
            onClicked: root.refreshWeather()
        }
    }
}
