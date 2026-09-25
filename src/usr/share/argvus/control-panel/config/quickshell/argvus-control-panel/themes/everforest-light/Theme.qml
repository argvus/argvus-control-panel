import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#3A94C5"
    readonly property color accentDim:       "#223A94C5"
    readonly property color accentMid:       "#553A94C5"
    readonly property color accentFaint:     "#0f3A94C5"
    readonly property color accentLight:     "#3A94C5"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#3A94C5"
    readonly property color fgText:          "#5C6A72"
    readonly property color fgDim:           "#829181"
    readonly property color fgSubtle:        "#939F91"
    readonly property color fgFaint:         "#A6B0A0"
    readonly property color fgOnAccent:      "#FDF6E3"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#FDF6E3"
    readonly property color bgPanel:         "#D9FDF6E3"   // panel with blur
    readonly property color bgCard:          "#f0E6E2CC"
    readonly property color bgCardAlt:       "#f0E0DCC7"
    readonly property color bgHeader:        "#f0E0DCC7"
    readonly property color bgItem:          "#14BDC3AF"
    readonly property color bgItemHover:     "#22E0DCC7"
    readonly property color bgActive:        "#22E8F1F4"

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#BDC3AF"
    readonly property color borderStrong:    "#3A94C5"
    readonly property color borderItem:      "#0fD8D5C3"
    readonly property color borderSubtle:    "#D8D5C3"

    // Scrollbar
    readonly property color scrollbarFg:      "#829181"
    readonly property color scrollbarBg:      "#E0DCC7"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#F85552"
    readonly property color dangerDim:       "#66F85552"
    readonly property color warn:            "#DFA000"
    readonly property color ok:              "#8DA101"

    // Typography --------------------------------------------------------------
    readonly property string fontMono:       "IBM Plex Mono"
    readonly property string fontIcon:       "Symbols Nerd Font Mono"

    // Form --------------------------------------------------------------------
    readonly property int radius:            0
    readonly property int radiusPill:        0
    readonly property int radiusSmall:       0

    // Animations --------------------------------------------------------------
    readonly property int animFast:          150
    readonly property int animNormal:        220

    // Position margins
    readonly property int marginTop:          1
    readonly property int marginBottom:       1
    readonly property int sidebarWidth:       350
    readonly property int marginRight:        1
}
