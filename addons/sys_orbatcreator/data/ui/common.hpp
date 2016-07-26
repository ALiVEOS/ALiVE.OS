#define GUI_GRID_X  (0)
#define GUI_GRID_Y  (0)
#define GUI_GRID_W  (0.025)
#define GUI_GRID_H  (0.04)
#define GUI_GRID_WAbs (1)
#define GUI_GRID_HAbs (1)

class RscText;
class RscButton;
class RscListBox;
class RscListNBox;
class RscFrame;

class orbatCreator_RscText : RscText {
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0.037;
    w = 0.3;
    class Attributes {
        font = "PuristaMedium";
        color = "#C0C0C0";
        align = "center";
        valign = "middle";
        shadow = false;
        shadowColor = "#000000";
    };
    style = 0;
    font = "PuristaMedium";
    SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    linespacing = 1;
};

class orbatCreator_RscPicture {
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] ={0,0,0,0};
    colorText[] ={1,1,1,1};
    font = "TahomaB";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};

class orbatCreator_RscEdit {
    access = 0;
    type = 2;
    x = 0;
    y = 0;
    h = 0.04;
    w = 0.2;
    colorBackground[] = {0,0,0,1};
    colorText[] = {0.95,0.95,0.95,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelection[] = {
        "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])",
        "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])",
        "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])",
        1
    };
    autocomplete = "";
    text = "";
    size = 0.2;
    style = "0x00 + 0x40";
    font = "PuristaMedium";
    shadow = 2;
    sizeEx = 0.0375;
    canModify = 1;
};

class orbatCreator_RscCombo {
    access = 0;
    type = 4;
    colorSelect[] = {0,0,0,1};
    colorText[] = {0.95,0.95,0.95,1};
    colorBackground[] = {0,0,0,1};
    color_Rscrollbar[] = {1,0,0,1};
    soundSelect[] =
    {
        "\A3\ui_f\data\sound\RscCombo\soundSelect",
        0.1,
        1
    };
    soundExpand[] =
    {
        "\A3\ui_f\data\sound\RscCombo\soundExpand",
        0.1,
        1
    };
    soundCollapse[] =
    {
        "\A3\ui_f\data\sound\RscCombo\soundCollapse",
        0.1,
        1
    };
    maxHistoryDelay = 1;
    class ComboScrollBar {
        width = 0;
        height = 0;
        scrollSpeed = 0.06;
        autoScrollDelay = 5;
        autoScrollEnabled = 0;
        autoScrollRewind = 0;
        autoScrollSpeed = -1;
        color[] = {1,1,1,0.6};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        shadow = 0;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
    style = 16;
    x = 0;
    y = 0;
    w = 0.12;
    h = 0.035;
    shadow = 0;
    colorSelectBackground[] ={1,1,1,0.7};
    arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\Rsccombo\arrow_combo_ca.paa";
    arrowFull = "\A3\ui_f\data\GUI\RscCommon\Rsccombo\arrow_combo_active_ca.paa";
    wholeHeight = 0.45;
    color[] = {1,1,1,1};
    colorActive[] = {1,0,0,1};
    colorDisabled[] = {1,1,1,0.25};
    font = "PuristaMedium";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};

class orbatCreator_RscFrame : RscFrame {
    colorBackground[] = {0,0,0,1};
    colorText[] = {1,1,1,1};
    font = "PuristaMedium";
    shadow = 2;
    sizeEx = 0.02;
    style = 0x40;
    text = "";
    type = 0;
};

class orbatCreator_RscButton : RscButton {
    access = 0;
    style = 2;
    type = 1;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelect[] = {0.4,0.416,0.42,1};
    colorSelect2[] = {0.4,0.416,0.42,1};
    colorFocused[] = {0.4,0.416,0.42,1};
    colorBackground[] = {0.4,0.416,0.42,1};
    colorBackgroundActive[] = {0.8,0.8,0.8,1};
    colorBackgroundDisabled[] = {0.4,0.416,0.42,0.7};
    class Attributes {
        font = "RobotoCondensed";
        color = "#C0C0C0";
        align = "center";
        valign = "middle";
        shadow = false;
        shadowColor = "#000000";
    };
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    borderSize = 0;
    colorBorder[] = {0,0,0,1};
    colorShadow[] = {0,0,0,0};
};

class orbatCreator_RscTree {
	access = 0;
	idc = 12;
	type = 12;
	style = 0;
	default = 0;
	enable = 1;
	show = 1;
	fade = 0;
	blinkingPeriod = 0;
                x = 0;
                y = 0;
                w = 0;
                h = 0;
                rowHeight = 0.5;
	colorBorder[] = {0,0,0,0};
	colorBackground[] = {0.2,0.2,0.2,1};
	colorSelect[] = {1,0.5,0,0.75};
	colorMarked[] = {1,0.5,0,0.5};
	colorMarkedSelected[] = {1,0.5,0,1};
	sizeEx = 0.05;
	font = "RobotoCondensed";
	shadow = 1;
	colorText[] = {1,1,1,1};
	colorSelectText[] = {1,1,1,1};
	colorMarkedText[] = {1,1,1,1};
	tooltip = "";
	tooltipColorShade[] = {0,0,0,1};
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	multiselectEnabled = 0;
	expandOnDoubleclick = 1;
	hiddenTexture = "A3\ui_f\data\gui\rsccommon\rsctree\hiddenTexture_ca.paa";
	expandedTexture = "A3\ui_f\data\gui\rsccommon\rsctree\expandedTexture_ca.paa";
                colorPicture[] = {1,1,1,1};
                colorPictureDisabled[] = {1,1,1,0.25};
                colorPictureRight[] = {1,1,1,1};
                colorPictureRightDisabled[] = {1,1,1,0.25};
                colorPictureRightSelected[] = {0,0,0,1};
                colorPictureSelected[] = {0,0,0,1};
                colorSearch[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])","(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"};
                colorSelectBackground[] = {0,0,0,0.5};
	maxHistoryDelay = 1;
	class ScrollBar
	{
                    width = 0;
                    height = 0;
                    scrollSpeed = 0.06;
                    arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                    arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                    border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                    thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                    color[] = {1,1,1,1};
	};
	colorDisabled[] = {0,0,0,0};
	colorArrow[] = {0,0,0,0};
};

class orbatCreator_RscListBox : RscListBox {
    style = 16;
    type = 5;
    rowHeight = 0.0375;
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorRsc_Rscrollbar[] = {1,0,0,0};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorSelectBackground[] = {0.95,0.95,0.95,1};
    colorSelectBackground2[] = {1,1,1,0.5};
    colorBackground[] = {0,0,0,0.3};
    font = "PuristaMedium";
    sizeEx = 0.035;
    colorShadow[] = {0,0,0,0.5};
    color[] = {1,1,1,1};
    period = 1.2;
};

class orbatCreator_RscListNBox : RscListNBox {
    style = "ST_LEFT + LB_TEXTURES";
    type = 102;
    rowHeight = .05;
    color[] = {1,1,1,1};
    colorPicture[] = {1,1,1,1};
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorSelectBackground[] ={0.95,0.95,0.95,1};
    colorSelectBackground2[] = {1,1,1,0.5};
    colorBackground[] = {0,0,0,0.3};
    colorPictureDisabled[] = {1,1,1,1};
    colorPictureSelected[] = {1,1,1,1};
    font = "PuristaMedium";
    period = 1;
    sizeEx = "(safeZoneH / 100) + (safeZoneH / 100)";
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    autoScrollSpeed = -1;
    arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
    arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
    drawSideArrows = 1;
};

class orbatCreator_RscStructuredText {
    access = 0;
    type = 13;
    idc = -1;
    style = 0;
    colorText[] = {1,1,1,1};
    class Attributes
    {
        font = "PuristaMedium";
        color = "#ffffff";
        align = "left";
        shadow = 1;
    };
    x = 0;
    y = 0;
    h = 0.035;
    w = 0.1;
    text = "";
    size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    shadow = 1;
};

class orbatCreator_RscControlsGroup {
    class VScrollbar
    {
        color[] = {1,1,1,1};
        width = 0.021;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
        shadow = 0;
    };
    class HScrollbar
    {
        color[] = {1,1,1,1};
        height = 0.028;
        shadow = 0;
    };
    class ScrollBar
    {
        color[] = {1,1,1,0.6};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        shadow = 0;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
    };
    class Controls
    {
    };
    type = 15;
    idc = -1;
    x = 0;
    y = 0;
    w = 1;
    h = 1;
    shadow = 0;
    style = 16;
};