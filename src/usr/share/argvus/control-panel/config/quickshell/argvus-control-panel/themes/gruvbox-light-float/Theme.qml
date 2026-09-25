import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#458588"
    readonly property color accentDim:       "#22458588"   // accent 13% opaco
    readonly property color accentMid:       "#55458588"   // accent 33% opaco
    readonly property color accentFaint:     "#0f458588"   // accent 6% opaco
    readonly property color accentLight:     "#458588"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#458588"
    readonly property color fgText:          "#3C3836"     // warm off-white
    readonly property color fgDim:           "#7C6F64"     // secondary text
    readonly property color fgSubtle:        "#7C6F64"     // muted
    readonly property color fgFaint:         "#928374"     // disabled
    readonly property color fgOnAccent:      "#3C3836"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#FBF1C7"
    readonly property color bgPanel:         "#D9F2E5BC" // panel with blur
    readonly property color bgCard:          "#FBF1C7"   // card bg
    readonly property color bgCardAlt:       "#EBDBB2"   // card alt
    readonly property color bgHeader:        "#EBDBB2"   // card header
    readonly property color bgItem:          "#14D5C4A1"   // item/row
    readonly property color bgItemHover:     "#22EBDBB2"   // item hover
    readonly property color bgActive:        "#22458588"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#BDAE93"
    readonly property color borderStrong:    "#458588"
    readonly property color borderItem:      "#0fBDAE93"
    readonly property color borderSubtle:    "#928374"

    // Scrollbar
    readonly property color scrollbarFg:    "#7C6F64"
    readonly property color scrollbarBg:    "#F2E5BC"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#CC241D"
    readonly property color dangerDim:       "#CC241D66"
    readonly property color warn:            "#D79921"
    readonly property color ok:              "#98971A"

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
