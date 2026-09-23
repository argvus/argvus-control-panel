import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#61AFEF"
    readonly property color accentDim:       "#222C465E"   // accent 13% opaco
    readonly property color accentMid:       "#5561AFEF"   // accent 33% opaco
    readonly property color accentFaint:     "#0F61AFEF"   // accent 6% opaco
    readonly property color accentLight:     "#61AFEF"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#61AFEF"     // highlight titles
    readonly property color fgText:          "#ABB2BF"     // warm off-white
    readonly property color fgDim:           "#828997"     // secondary text
    readonly property color fgSubtle:        "#5C6370"     // muted
    readonly property color fgFaint:         "#4B596A"     // disabled
    readonly property color fgOnAccent:      "#282C34"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#21252B"
    readonly property color bgPanel:         "#D021252B"   // panel with blur
    readonly property color bgCard:          "#D02C313A"   // card bg
    readonly property color bgCardAlt:       "#D0353B45"   // card alt
    readonly property color bgHeader:        "#D021252B"   // card header
    readonly property color bgItem:          "#143E4451"   // item/row
    readonly property color bgItemHover:     "#22494B5E"   // item hover
    readonly property color bgActive:        "#222C465E"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#222C465E"   // card border
    readonly property color borderStrong:    "#5561AFEF"   // hover/highlight
    readonly property color borderItem:      "#0F61AFEF"   // inner item
    readonly property color borderSubtle:    "#3E4451"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#5C6370"
    readonly property color scrollbarBg:    "#2C313A"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#49363A"
    readonly property color dangerDim:       "#49363A66"
    readonly property color warn:            "#494230"
    readonly property color ok:              "#344238"

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
