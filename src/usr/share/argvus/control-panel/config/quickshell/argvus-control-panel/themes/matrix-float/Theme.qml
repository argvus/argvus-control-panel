import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#82FB9C"
    readonly property color accentDim:       "#2282FB9C"   // accent 13% opaco
    readonly property color accentMid:       "#5582FB9C"   // accent 33% opaco
    readonly property color accentFaint:     "#0f82FB9C"   // accent 6% opaco
    readonly property color accentLight:     "#82FB9C"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#82FB9C"     // highlight titles
    readonly property color fgText:          "#DDF7FF"     // warm off-white
    readonly property color fgDim:           "#A7BEC5"     // secondary text
    readonly property color fgSubtle:        "#788B92"     // muted
    readonly property color fgFaint:         "#56656B"     // disabled
    readonly property color fgOnAccent:      "#0B0C16"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#0B0C16"
    readonly property color bgPanel:         "#d00B0C16"   // panel with blur
    readonly property color bgCard:          "#d0141722"   // card bg
    readonly property color bgCardAlt:       "#d01A1D29"   // card alt
    readonly property color bgHeader:        "#d028231F"   // card header
    readonly property color bgItem:          "#1429303A"   // item/row
    readonly property color bgItemHover:     "#22141722"   // item hover
    readonly property color bgActive:        "#2282FB9C"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#2282FB9C"   // card border
    readonly property color borderStrong:    "#5582FB9C"   // hover/highlight
    readonly property color borderItem:      "#0f82FB9C"   // inner item
    readonly property color borderSubtle:    "#29303A"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#788B92"
    readonly property color scrollbarBg:    "#141722"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#FF6B7A"
    readonly property color dangerDim:       "#FF6B7A66"
    readonly property color warn:            "#E5D57A"
    readonly property color ok:              "#A7BEC5"

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
