import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#0969DA"
    readonly property color accentDim:       "#220969DA"
    readonly property color accentMid:       "#550969DA"
    readonly property color accentFaint:     "#0f0969DA"
    readonly property color accentLight:     "#0969DA"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#0969DA"
    readonly property color fgText:          "#24292F"     // warm off-white
    readonly property color fgDim:           "#57606A"     // secondary text
    readonly property color fgSubtle:        "#57606A"     // muted
    readonly property color fgFaint:         "#8C959F"
    readonly property color fgOnAccent:      "#FFFFFF"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#F6F8FA"
    readonly property color bgPanel:         "#F6F8FA"
    readonly property color bgCard:          "#FFFFFF"
    readonly property color bgCardAlt:       "#F1F4F7"
    readonly property color bgHeader:        "#EFF2F5"
    readonly property color bgItem:          "#14D0D7DE"
    readonly property color bgItemHover:     "#22C9D2DC"
    readonly property color bgActive:        "#22DDF4FF"

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
