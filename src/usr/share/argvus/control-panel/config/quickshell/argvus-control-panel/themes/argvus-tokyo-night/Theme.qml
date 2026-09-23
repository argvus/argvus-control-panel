import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#7AA2F7"
    readonly property color accentDim:       "#227AA2F7"   // accent 13% opaco
    readonly property color accentMid:       "#557AA2F7"   // accent 33% opaco
    readonly property color accentFaint:     "#0f7AA2F7"   // accent 6% opaco
    readonly property color accentLight:     "#7AA2F7"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#7AA2F7"     // highlight titles
    readonly property color fgText:          "#C0CAF5"     // warm off-white
    readonly property color fgDim:           "#A9B1D6"     // secondary text
    readonly property color fgSubtle:        "#565F89"     // muted
    readonly property color fgFaint:         "#3B4261"     // disabled
    readonly property color fgOnAccent:      "#1A1B26"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#1A1B26"
    readonly property color bgPanel:         "#d01A1B26"   // panel with blur
    readonly property color bgCard:          "#d0292E42"   // card bg
    readonly property color bgCardAlt:       "#d024283B"   // card alt
    readonly property color bgHeader:        "#d016161E"   // card header
    readonly property color bgItem:          "#143B4261"   // item/row
    readonly property color bgItemHover:     "#22404B5E"   // item hover
    readonly property color bgActive:        "#227AA2F7"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#227AA2F7"   // card border
    readonly property color borderStrong:    "#557AA2F7"   // hover/highlight
    readonly property color borderItem:      "#0f7AA2F7"   // inner item
    readonly property color borderSubtle:    "#3B4261"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#565F89"
    readonly property color scrollbarBg:    "#292E42"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#F7768E"
    readonly property color dangerDim:       "#F7768E66"
    readonly property color warn:            "#E0AF68"
    readonly property color ok:              "#9ECE6A"

    // Tipography --------------------------------------------------------------
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

