import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#E2BE8A"
    readonly property color accentDim:       "#22E2BE8A"   // accent 13% opaco
    readonly property color accentMid:       "#55E2BE8A"   // accent 33% opaco
    readonly property color accentFaint:     "#0fE2BE8A"   // accent 6% opaco
    readonly property color accentLight:     "#E2BE8A"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#E2BE8A"     // highlight titles
    readonly property color fgText:          "#EADCCC"     // warm off-white
    readonly property color fgDim:           "#CEA37F"     // secondary text
    readonly property color fgSubtle:        "#A98C72"     // muted
    readonly property color fgFaint:         "#706A6A"     // disabled
    readonly property color fgOnAccent:      "#0F0F0F"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#0F0F0F"
    readonly property color bgPanel:         "#d00F0F0F"   // panel with blur
    readonly property color bgCard:          "#d01A1816"   // card bg
    readonly property color bgCardAlt:       "#d0211E1B"   // card alt
    readonly property color bgHeader:        "#d028231F"   // card header
    readonly property color bgItem:          "#143A332D"   // item/row
    readonly property color bgItemHover:     "#221A1816"   // item hover
    readonly property color bgActive:        "#22E2BE8A"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22E2BE8A"   // card border
    readonly property color borderStrong:    "#55E2BE8A"   // hover/highlight
    readonly property color borderItem:      "#0fE2BE8A"   // inner item
    readonly property color borderSubtle:    "#3A332D"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#A98C72"
    readonly property color scrollbarBg:    "#1A1816"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#E25D6C"
    readonly property color dangerDim:       "#E25D6C66"
    readonly property color warn:            "#F4BB54"
    readonly property color ok:              "#CEA37F"

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
