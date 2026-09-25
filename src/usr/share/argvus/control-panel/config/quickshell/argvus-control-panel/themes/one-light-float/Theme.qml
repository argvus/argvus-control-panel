import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#4078F2"
    readonly property color accentDim:       "#224078F2"
    readonly property color accentMid:       "#554078F2"
    readonly property color accentFaint:     "#0f4078F2"
    readonly property color accentLight:     "#4078F2"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#4078F2"
    readonly property color fgText:          "#383A42"
    readonly property color fgDim:           "#696C77"
    readonly property color fgSubtle:        "#A0A1A7"
    readonly property color fgFaint:         "#B6BDC6"
    readonly property color fgOnAccent:      "#FFFFFF"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#FAFAFA"
    readonly property color bgPanel:         "#D9F0F0F1"   // panel with blur
    readonly property color bgCard:          "#FFFFFF"
    readonly property color bgCardAlt:       "#F4F4F5"
    readonly property color bgHeader:        "#F4F4F5"
    readonly property color bgItem:          "#E8EEFD"
    readonly property color bgItemHover:     "#E8EAED"
    readonly property color bgActive:        "#4078F2"

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#D7DAE0"
    readonly property color borderStrong:    "#4078F2"
    readonly property color borderItem:      "#E5E7EB"
    readonly property color borderSubtle:    "#D7DAE0"

    // Scrollbar
    readonly property color scrollbarFg:      "#696C77"
    readonly property color scrollbarBg:      "#F0F0F1"

    // Status ------------------------------------------------------------------
    readonly property color danger:           "#E45649"
    readonly property color dangerDim:       "#66E45649"
    readonly property color warn:             "#C18401"
    readonly property color ok:               "#50A14F"

    // Typography --------------------------------------------------------------
    readonly property string fontMono:        "IBM Plex Mono"
    readonly property string fontIcon:        "Symbols Nerd Font Mono"

    // Form --------------------------------------------------------------------
    readonly property int radius:             8
    readonly property int radiusPill:         18
    readonly property int radiusSmall:        4

    // Animations --------------------------------------------------------------
    readonly property int animFast:           150
    readonly property int animNormal:         220

    // Position margins
    readonly property int marginTop:          15
    readonly property int marginBottom:       15
    readonly property int sidebarWidth:       350
    readonly property int marginRight:        15
}
