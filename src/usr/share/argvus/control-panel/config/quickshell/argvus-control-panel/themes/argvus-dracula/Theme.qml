import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#BD93F9"
    readonly property color accentDim:       "#22BD93F9"   // accent 13% opaco
    readonly property color accentMid:       "#55BD93F9"   // accent 33% opaco
    readonly property color accentFaint:     "#0fBD93F9"   // accent 6% opaco
    readonly property color accentLight:     "#BD93F9"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#BD93F9"     // highlight titles
    readonly property color fgText:          "#F8F8F2"     // warm off-white
    readonly property color fgDim:           "#6272A4"     // secondary text
    readonly property color fgSubtle:        "#6272A4"     // muted
    readonly property color fgFaint:         "#6272A4"     // disabled
    readonly property color fgOnAccent:      "#282A36"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#282A36"
    readonly property color bgPanel:         "#d0282A36"   // panel with blur
    readonly property color bgCard:          "#d0343746"   // card bg
    readonly property color bgCardAlt:       "#d021222C"   // card alt
    readonly property color bgHeader:        "#d0191A21"   // card header
    readonly property color bgItem:          "#1444475A"   // item/row
    readonly property color bgItemHover:     "#22404B5E"   // item hover
    readonly property color bgActive:        "#22BD93F9"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22BD93F9"   // card border
    readonly property color borderStrong:    "#55BD93F9"   // hover/highlight
    readonly property color borderItem:      "#0fBD93F9"   // inner item
    readonly property color borderSubtle:    "#44475A"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#6272A4"
    readonly property color scrollbarBg:    "#343746"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#DE5735"
    readonly property color dangerDim:       "#DE573566"
    readonly property color warn:            "#A39514"
    readonly property color ok:              "#089108"

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
