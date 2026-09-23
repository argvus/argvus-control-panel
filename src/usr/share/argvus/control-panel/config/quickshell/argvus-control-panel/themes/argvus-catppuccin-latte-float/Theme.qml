import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#4C4F69"
    readonly property color accentDim:       "#22ACB0BE"   // accent 13% opaco
    readonly property color accentMid:       "#55ACB0BE"   // accent 33% opaco
    readonly property color accentFaint:     "#0f4C4F69"   // accent 6% opaco
    readonly property color accentLight:     "#4C4F69"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#4C4F69"     // gold titles
    readonly property color fgText:          "#4C4F69"     // warm off-white
    readonly property color fgDim:           "#5C5F77"     // secondary text
    readonly property color fgSubtle:        "#6C6F85"     // muted
    readonly property color fgFaint:         "#9CA0B0"     // disabled
    readonly property color fgOnAccent:      "#EFF1F5"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#EFF1F5"
    readonly property color bgPanel:         "#f0EFF1F5"   // panel with blur
    readonly property color bgCard:          "#f0E6E9EF"   // card bg
    readonly property color bgCardAlt:       "#f0CCD0DA"   // card alt
    readonly property color bgHeader:        "#f0E6E9EF"   // card header
    readonly property color bgItem:          "#14ACB0BE"   // item/row
    readonly property color bgItemHover:     "#22DCE0E8"   // item hover
    readonly property color bgActive:        "#22ACB0BE"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22ACB0BE"   // card border
    readonly property color borderStrong:    "#55ACB0BE"   // hover/highlight
    readonly property color borderItem:      "#0f4C4F69"   // inner item
    readonly property color borderSubtle:    "#ACB0BE"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#6C6F85"
    readonly property color scrollbarBg:    "#E6E9EF"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#D20F39"
    readonly property color dangerDim:       "#D20F3966"
    readonly property color warn:            "#DF8E1D"
    readonly property color ok:              "#40A02B"

    // Tipography --------------------------------------------------------------
    readonly property string fontMono:       "IBM Plex Mono"
    readonly property string fontIcon:       "Symbols Nerd Font Mono"

    // Form --------------------------------------------------------------------
    readonly property int radius:            8
    readonly property int radiusPill:        18
    readonly property int radiusSmall:       4

    // Animations --------------------------------------------------------------
    readonly property int animFast:          150
    readonly property int animNormal:        220

    // Position margins
    readonly property int marginTop:          15
    readonly property int marginBottom:       15
    readonly property int sidebarWidth:       350
    readonly property int marginRight:        15
}
