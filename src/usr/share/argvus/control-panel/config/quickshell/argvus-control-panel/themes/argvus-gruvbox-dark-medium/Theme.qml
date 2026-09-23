import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#D79921"
    readonly property color accentDim:       "#22D79921"   // accent 13% opaco
    readonly property color accentMid:       "#55D79921"   // accent 33% opaco
    readonly property color accentFaint:     "#0fD79921"   // accent 6% opaco
    readonly property color accentLight:     "#D79921"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#D79921"     // highlight titles
    readonly property color fgText:          "#EBDBB2"     // warm off-white
    readonly property color fgDim:           "#A89984"     // secondary text
    readonly property color fgSubtle:        "#928374"     // muted
    readonly property color fgFaint:         "#928374"     // disabled
    readonly property color fgOnAccent:      "#282828"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#282828"
    readonly property color bgPanel:         "#d0282828"   // panel with blur
    readonly property color bgCard:          "#d0504945"   // card bg
    readonly property color bgCardAlt:       "#d03C3836"   // card alt
    readonly property color bgHeader:        "#d03C3836"   // card header
    readonly property color bgItem:          "#14665C54"   // item/row
    readonly property color bgItemHover:     "#22504945"   // item hover
    readonly property color bgActive:        "#22D79921"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22D79921"   // card border
    readonly property color borderStrong:    "#55D79921"   // hover/highlight
    readonly property color borderItem:      "#0fD79921"   // inner item
    readonly property color borderSubtle:    "#665C54"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#928374"
    readonly property color scrollbarBg:    "#504945"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#CC241D"
    readonly property color dangerDim:       "#CC241D66"
    readonly property color warn:            "#D79921"
    readonly property color ok:              "#98971A"

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
