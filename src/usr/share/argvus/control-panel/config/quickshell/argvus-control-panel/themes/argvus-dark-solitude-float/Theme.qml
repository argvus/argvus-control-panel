import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#798186"
    readonly property color accentDim:       "#22798186"   // accent 13% opaco
    readonly property color accentMid:       "#55798186"   // accent 33% opaco
    readonly property color accentFaint:     "#0f798186"   // accent 6% opaco
    readonly property color accentLight:     "#798186"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#798186"     // highlight titles
    readonly property color fgText:          "#CACCCC"     // warm off-white
    readonly property color fgDim:           "#9FA5A9"     // secondary text
    readonly property color fgSubtle:        "#798186"     // muted
    readonly property color fgFaint:         "#565D60"     // disabled
    readonly property color fgOnAccent:      "#101315"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#101315"
    readonly property color bgPanel:         "#d0101315"   // panel with blur
    readonly property color bgCard:          "#d01A1E20"   // card bg
    readonly property color bgCardAlt:       "#d0202528"   // card alt
    readonly property color bgHeader:        "#d0202528"   // card header
    readonly property color bgItem:          "#14343D41"   // item/row
    readonly property color bgItemHover:     "#22202528"   // item hover
    readonly property color bgActive:        "#22798186"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22798186"   // card border
    readonly property color borderStrong:    "#55798186"   // hover/highlight
    readonly property color borderItem:      "#0f798186"   // inner item
    readonly property color borderSubtle:    "#343D41"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#798186"
    readonly property color scrollbarBg:    "#1A1E20"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#DE6145"
    readonly property color dangerDim:       "#DE614566"
    readonly property color warn:            "#C9C2B4"
    readonly property color ok:              "#798186"

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
