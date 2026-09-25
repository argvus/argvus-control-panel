import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#C4A7E7"
    readonly property color accentDim:       "#22C4A7E7"   // accent 13% opaco
    readonly property color accentMid:       "#55C4A7E7"   // accent 33% opaco
    readonly property color accentFaint:     "#0fC4A7E7"   // accent 6% opaco
    readonly property color accentLight:     "#EBBCBA"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#C4A7E7"     // highlight titles
    readonly property color fgText:          "#E0DEF4"     // warm off-white
    readonly property color fgDim:           "#908CAA"     // secondary text
    readonly property color fgSubtle:        "#6E6A86"     // muted
    readonly property color fgFaint:         "#524F67"     // disabled
    readonly property color fgOnAccent:      "#191724"     // text on accent

    // Background --------------------------------------------------------------
    readonly property color bg:              "#191724"
    readonly property color bgPanel:         "#d0191724"   // panel with blur
    readonly property color bgCard:          "#d026233A"   // card bg
    readonly property color bgCardAlt:       "#d021202E"   // card alt
    readonly property color bgHeader:        "#d026233A"   // card header
    readonly property color bgItem:          "#14403D52"   // item/row
    readonly property color bgItemHover:     "#22404B5E"   // item hover
    readonly property color bgActive:        "#22C4A7E7"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#22C4A7E7"   // card border
    readonly property color borderStrong:    "#55C4A7E7"   // hover/highlight
    readonly property color borderItem:      "#0fC4A7E7"   // inner item
    readonly property color borderSubtle:    "#403D52"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#6E6A86"
    readonly property color scrollbarBg:    "#26233A"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#EB6F92"
    readonly property color dangerDim:       "#EB6F9266"
    readonly property color warn:            "#F6C177"
    readonly property color ok:              "#31748F"

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
