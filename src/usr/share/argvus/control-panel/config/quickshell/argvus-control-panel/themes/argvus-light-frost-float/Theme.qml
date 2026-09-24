import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#0969DA"
    readonly property color accentDim:       "#220969DA"   // accent 13% opaco
    readonly property color accentMid:       "#550969DA"   // accent 33% opaco
    readonly property color accentFaint:     "#0f0969DA"   // accent 6% opaco
    readonly property color accentLight:     "#0969DA"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#0969DA"
    readonly property color fgText:          "#24292F"     // warm off-white
    readonly property color fgDim:           "#57606A"     // secondary text
    readonly property color fgSubtle:        "#57606A"     // muted
    readonly property color fgFaint:         "#8C959F"     // disabled
    readonly property color fgOnAccent:      "#FFFFFF"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#F6F8FA"
    readonly property color bgPanel:         "#F6F8FA"   // panel with blur
    readonly property color bgCard:          "#FFFFFF"   // card bg
    readonly property color bgCardAlt:       "#EFF2F5"   // card alt
    readonly property color bgHeader:        "#EFF2F5"   // card header
    readonly property color bgItem:          "#14D0D7DE"   // item/row
    readonly property color bgItemHover:     "#22C9D2DC"   // item hover
    readonly property color bgActive:        "#220969DA"   // active state

    // Borders -----------------------------------------------------------------
    readonly property color border:          "#B8C1CC"
    readonly property color borderStrong:    "#0969DA"
    readonly property color borderItem:      "#0fB8C1CC"
    readonly property color borderSubtle:    "#D0D7DE"

    // Scrollbar
    readonly property color scrollbarFg:    "#57606A"
    readonly property color scrollbarBg:    "#F1F4F7"

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
