import QtQuick

QtObject {
    // Accent ------------------------------------------------------------------
    readonly property color accent:          "#458588"
    readonly property color accentDim:       "#22458588"
    readonly property color accentMid:       "#55458588"
    readonly property color accentFaint:     "#0f458588"
    readonly property color accentLight:     "#458588"

    // Foreground --------------------------------------------------------------
    readonly property color fgTitle:         "#458588"
    readonly property color fgText:          "#3C3836"     // warm off-white
    readonly property color fgDim:           "#7C6F64"     // secondary text
    readonly property color fgSubtle:        "#7C6F64"     // muted
    readonly property color fgFaint:         "#928374"
    readonly property color fgOnAccent:      "#3C3836"

    // Background --------------------------------------------------------------
    readonly property color bg:              "#FBF1C7"
    readonly property color bgPanel:         "#F2E5BC"
    readonly property color bgCard:          "#FBF1C7"
    readonly property color bgCardAlt:       "#EBDBB2"
    readonly property color bgHeader:        "#EBDBB2"
    readonly property color bgItem:          "#14D5C4A1"
    readonly property color bgItemHover:     "#22EBDBB2"
    readonly property color bgActive:        "#22D5C4A1"

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
