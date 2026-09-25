import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#0969DA"
    readonly property color accentDim:       "#220969DA"   // accent 13% opaco
    readonly property color accentMid:       "#550969DA"   // accent 33% opaco
    readonly property color accentFaint:     "#0f0969DA"   // accent 6% opaco
    readonly property color accentLight:     "#0969DA"     // destaque para titulos

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#0969DA"     // accent titles
    readonly property color fgText:          "#1F2328"     // warm off-white
    readonly property color fgDim:           "#57606A"     // secondary text
    readonly property color fgSubtle:        "#6E7781"     // muted
    readonly property color fgFaint:         "#8C959F"     // disabled
    readonly property color fgOnAccent:      "#FFFFFF"     // text on gold

    // Background --------------------------------------------------------------
    readonly property color bg:              "#FFFFFF"
    readonly property color bgPanel:         "#f0FFFFFF"   // panel with blur
    readonly property color bgCard:          "#f0F6F8FA"   // card bg
    readonly property color bgCardAlt:       "#f0EAECEF"   // card alt
    readonly property color bgHeader:        "#f0EAECEF"   // card header
    readonly property color bgItem:          "#14D0D7DE"   // item/row
    readonly property color bgItemHover:     "#22EAECEF"   // item hover
    readonly property color bgActive:        "#22DDF4FF"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#D0D7DE"     // card border
    readonly property color borderStrong:    "#0969DA"     // hover/highlight
    readonly property color borderItem:      "#EAECEF"     // inner item
    readonly property color borderSubtle:    "#D0D7DE"     // neutral

    // Scrollbar
    readonly property color scrollbarFg:    "#6E7781"
    readonly property color scrollbarBg:    "#F6F8FA"

    // Status ------------------------------------------------------------------
    readonly property color danger:          "#CF222E"
    readonly property color dangerDim:       "#CF222E66"
    readonly property color warn:            "#9A6700"
    readonly property color ok:              "#1A7F37"

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
