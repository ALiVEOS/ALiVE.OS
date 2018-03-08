#define GUI_GRID_X  (0)
#define GUI_GRID_Y  (0)
#define GUI_GRID_W  (0.025)
#define GUI_GRID_H  (0.04)
#define GUI_GRID_WAbs (1)
#define GUI_GRID_HAbs (1)

// colors

#define COLOR_ARMA_BG               {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.77])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.51])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.08])","(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"}

#define COLOR_WHITE(alpha)          {1,1,1,alpha}
#define COLOR_WHITE_HARD            COLOR_WHITE(1)
#define COLOR_WHITE_MODERATE        COLOR_WHITE(0.8)
#define COLOR_WHITE_SOFT            COLOR_WHITE(0.7)

#define COLOR_BLACK(alpha)          {0,0,0,alpha}
#define COLOR_BLACK_HARD            COLOR_BLACK(1)
#define COLOR_BLACK_MODERATE        COLOR_BLACK(0.8)
#define COLOR_BLACK_SOFT            COLOR_BLACK(0.7)

#define COLOR_GREY(alpha)           {0.2,0.2,0.2,alpha}
#define COLOR_GREY_HARD             COLOR_GREY(1)
#define COLOR_GREY_MODERATE         COLOR_GREY(0.8)
#define COLOR_GREY_SOFT             COLOR_GREY(0.7)

#define COLOR_GREY_LIGHT(alpha)     {0.4,0.416,0.42,alpha}
#define COLOR_GREY_LIGHT_HARD       COLOR_GREY(1)
#define COLOR_GREY_LIGHT_MODERATE   COLOR_GREY(0.8)
#define COLOR_GREY_LIGHT_SOFT       COLOR_GREY(0.7)

#define COLOR_GREY_DARK(alpha)      {0.15,0.15,0.15,alpha}
#define COLOR_GREY_DARK_HARD        COLOR_GREY_DARK(1)
#define COLOR_GREY_DARK_MODERATE    COLOR_GREY_DARK(0.8)
#define COLOR_GREY_DARK_SOFT        COLOR_GREY_DARK(0.7)

#define COLOR_GREY_TITLE(alpha)      {0.678,0.678,0.678,alpha}
#define COLOR_GREY_TITLE_HARD        COLOR_GREY_TITLE(1)
#define COLOR_GREY_TITLE_MODERATE    COLOR_GREY_TITLE(0.8)
#define COLOR_GREY_TITLE_SOFT        COLOR_GREY_TITLE(0.7)

#define COLOR_GREEN(alpha)          {0.576,0.769,0.49,alpha}
#define COLOR_GREEN_HARD            COLOR_GREEN(1)
#define COLOR_GREEN_MODERATE        COLOR_GREEN(0.8)
#define COLOR_GREEN_SOFT            COLOR_GREEN(0.7)

// controls

#define BASE_SIZE_TEXT          (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)
#define BASE_SIZE_TEXT_LISTBOX  (safeZoneH / 100) + (safeZoneH / 100)

class RscText;
class orbatCreator_RscText : RscText {
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = COLOR_BLACK(0);
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0.037;
    w = 0.3;
    style = 0;
    font = "PuristaMedium";
    SizeEx = BASE_SIZE_TEXT;
    linespacing = 1;
};

class orbatCreator_RscPicture {
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] = COLOR_BLACK_HARD;
    colorText[] ={1,1,1,1};
    font = "TahomaB";
    sizeEx = BASE_SIZE_TEXT;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};

class RscEdit;
class orbatCreator_RscEdit : RscEdit {
    access = 0;
    type = 2;
    x = 0;
    y = 0;
    h = 0.04;
    w = 0.2;
    colorBackground[] = COLOR_GREY_HARD;
    colorText[] = {0.95,0.95,0.95,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelection[] = COLOR_ARMA_BG;
    autocomplete = "";
    text = "";
    size = 0.2;
    style = "0x00 + 0x40";
    font = "PuristaMedium";
    shadow = 2;
    sizeEx = BASE_SIZE_TEXT;
    canModify = 1;
};

class orbatCreator_RscCombo {
    access = 0;
    type = 4;
    colorSelect[] = {0,0,0,1};
    colorText[] = {0.95,0.95,0.95,1};
    colorBackground[] = COLOR_BLACK_HARD;
    color_Rscrollbar[] = {1,0,0,1};
    colorPicture[] = {1,1,1,1};
    colorPictureSelected[] = {1,1,1,1};
    colorPictureDisabled[] = {1,1,1,1};
    soundSelect[] = {
        "\A3\ui_f\data\sound\RscCombo\soundSelect",
        0.1,
        1
    };
    soundExpand[] = {
        "\A3\ui_f\data\sound\RscCombo\soundExpand",
        0.1,
        1
    };
    soundCollapse[] = {
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
        color[] = COLOR_WHITE(0.6);
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        shadow = 0;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
    style = 0x10 + 0x200;
    //style = 16;
    x = 0;
    y = 0;
    w = 0.12;
    h = 0.035;
    shadow = 0;
    colorSelectBackground[] ={1,1,1,0.7};
    arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\Rsccombo\arrow_combo_ca.paa";
    arrowFull = "\A3\ui_f\data\GUI\RscCommon\Rsccombo\arrow_combo_active_ca.paa";
    wholeHeight = 0.45;
    color[] = COLOR_WHITE_HARD;
    colorActive[] = {1,0,0,1};
    colorDisabled[] = {1,1,1,0.25};
    font = "PuristaMedium";
    sizeEx = BASE_SIZE_TEXT;
};

class RscFrame;
class orbatCreator_RscFrame : RscFrame {
    colorBackground[] = COLOR_BLACK_HARD;
    colorText[] = {1,1,1,1};
    font = "PuristaMedium";
    shadow = 2;
    sizeEx = BASE_SIZE_TEXT;
    style = 0x40;
    text = "";
    type = 0;
};

class RscButton;
class orbatCreator_RscButton : RscButton {
    access = 0;
    type = 1;
    style = 2;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelect[] = COLOR_GREY_LIGHT_HARD;
    colorSelect2[] = COLOR_GREY_LIGHT_HARD;
    colorFocused[] = COLOR_GREY_LIGHT_HARD;
    colorBackground[] = COLOR_GREY_LIGHT_HARD;
    colorBackgroundDisabled[] = COLOR_BLACK(0.5);
    colorBackgroundActive[] = COLOR_ARMA_BG;
    class Attributes {
        font = "RobotoCondensed";
        color = "#C0C0C0";
        align = "middle";
        valign = "middle";
        shadow = false;
        shadowColor = "#000000";
    };
    font = "RobotoCondensed";
    fade = 0;
    sizeEx = BASE_SIZE_TEXT;
    borderSize = 0;
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,1};
};

class orbatCreator_RscButtonBig : orbatCreator_RscButton {
    colorSelect[] = COLOR_GREY_HARD;
    colorSelect2[] = COLOR_GREY_HARD;
    colorFocused[] = COLOR_GREY_HARD;
    colorBackground[] = COLOR_GREY_HARD;
    font = "RobotoCondensed";
    borderSize = 0;
    colorShadow[] = COLOR_BLACK(0);
    colorBorder[] = COLOR_BLACK_HARD;
};

class ctrlButtonOK;
class orbatCreator_ctrlButtonOk : ctrlButtonOK {

};

class ctrlButtonCancel;
class orbatCreator_ctrlButtonCancel : ctrlButtonCancel {

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
	colorBackground[] = COLOR_BLACK_HARD;
	colorSelect[] = {1,0.5,0,0.75};
	colorMarked[] = {1,0.5,0,0.5};
	colorMarkedSelected[] = {1,0.5,0,1};
	sizeEx = BASE_SIZE_TEXT;
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
	class ScrollBar {
        width = 0;
        height = 0;
        scrollSpeed = 0.06;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        color[] = COLOR_WHITE_HARD;
	};
	colorDisabled[] = {0,0,0,0};
	colorArrow[] = {0,0,0,0};
};

class RscListBox;
class orbatCreator_RscListBox : RscListBox {
    access = 0;
    style = 16;
    type = 5;
    rowHeight = 0.0375;
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorRsc_Rscrollbar[] = {1,0,0,0};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorSelectBackground[] = {1,0.5,0,0.75};
    colorSelectBackground2[] = {1,0.5,0,0.75};
    colorBackground[] = COLOR_GREY_HARD;
    font = "PuristaMedium";
    sizeEx = BASE_SIZE_TEXT;
    colorShadow[] = {0,0,0,0.5};
    color[] = COLOR_WHITE_HARD;
    period = 1.2;
};

class RscListNBox;
class orbatCreator_RscListNBox : RscListNBox {
    style = "ST_LEFT + LB_TEXTURES";
    type = 102;
    rowHeight = .05;
    color[] = COLOR_WHITE_HARD;
    colorPicture[] = {1,1,1,1};
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorSelectBackground[] ={0.95,0.95,0.95,1};
    colorSelectBackground2[] = {1,1,1,0.5};
    colorBackground[] = COLOR_GREY_HARD;
    colorPictureDisabled[] = {1,1,1,1};
    colorPictureSelected[] = {1,1,1,1};
    font = "PuristaMedium";
    period = 1;
    sizeEx = BASE_SIZE_TEXT_LISTBOX;
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
    class Attributes {
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
    size = BASE_SIZE_TEXT;
    shadow = 1;
};

class orbatCreator_RscControlsGroup {
    idc = -1;
    type = 15;
    style = 16;
    shadow = 0;
    fade = 0;
    deletable = 0;
    x = 0;
    y = 0;
    w = 1;
    h = 1;

    class HScrollbar {
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        autoScrollDelay = 5;
        autoScrollEnabled = 0;
        autoScrollRewind = 0;
        autoScrollSpeed = -1;
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        color[] = {1,1,1,1};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        height = 0.028;
        scrollSpeed = 0.06;
        shadow = 0;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        width = 0;
    };

    class VScrollbar {
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        autoScrollDelay = 5;
        autoScrollEnabled = 0;
        autoScrollRewind = 0;
        autoScrollSpeed = -1;
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        color[] = {1,1,1,1};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        height = 0.028;
        scrollSpeed = 0.06;
        shadow = 0;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        width = 0.021 * 0.75;
    };
};

class orbatCreator_RscControlsGroupNoScrollbars {
    idc = -1;
    type = 15;
    style = 16;
    shadow = 0;
    fade = 0;
    deletable = 0;
    x = 0;
    y = 0;
    w = 1;
    h = 1;

    class HScrollbar {
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        autoScrollDelay = 5;
        autoScrollEnabled = 0;
        autoScrollRewind = 0;
        autoScrollSpeed = -1;
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        color[] = {1,1,1,1};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        height = 0;
        scrollSpeed = 0.06;
        shadow = 0;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        width = 0;
    };

    class VScrollbar {
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        autoScrollDelay = 5;
        autoScrollEnabled = 0;
        autoScrollRewind = 0;
        autoScrollSpeed = -1;
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        color[] = {1,1,1,1};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        height = 0.028;
        scrollSpeed = 0.06;
        shadow = 0;
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        width = 0;
    };
};

class ctrlMenuStrip;
class orbatCreator_ctrlMenuStrip : ctrlMenuStrip {
    sizeEx = BASE_SIZE_TEXT * 0.85;

    class Items {
        items[] = {};

        class Default {
            enable = 0;
            text = "Empty";
        };
    };
};



class orbatCreator_common_backgroundGrid: orbatCreator_RscPicture {
    idc = 7001;
    text = "x\alive\addons\ui\alive_bg.paa";
    x = -0.003125 * safezoneW + safezoneX;
    y = -0.00399999 * safezoneH + safezoneY;
    w = 1.00625 * safezoneW;
    h = 1.008 * safezoneH;
};

class orbatCreator_common_header_green : orbatCreator_RscText {
    idc = 7002;

	x = -0.003125 * safezoneW + safezoneX;
	y = -0.000359978 * safezoneH + safezoneY;
	w = 1.00625 * safezoneW;
	h = 0.0392 * safezoneH;
    colorBackground[] = COLOR_GREEN_HARD;
};

class orbatCreator_common_header_interfaceTitle : orbatCreator_RscText {
    idc = 7003;

    text = "Faction Editor";
	x = 0.0078125 * safezoneW + safezoneX;
	y = -0.0034 * safezoneH + safezoneY;
	w = 0.21875 * safezoneW;
	h = 0.0392 * safezoneH;
    sizeEx = BASE_SIZE_TEXT * 1.10;
    colorBackground[] = COLOR_BLACK(0);
};

class orbatCreator_common_header_banner : orbatCreator_RscPicture {
    idc = 7004;
    style = 48 + 0x800;

    text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
	x = 0.70 * safezoneW + safezoneX;
	y = -0.000359978 * safezoneH + safezoneY;
	w = 0.35 * safezoneW;
	h = 0.0392 * safezoneH;
};

class menuStrip_button_action {

    action = "['onMenuStripButtonClicked', _this] call ALiVE_fnc_orbatCreatorOnAction";

};

class orbatCreator_common_header_menuStrip : orbatCreator_ctrlMenuStrip {
    idc = 7005;

	x = safezoneX;
	y = 0.038 * safezoneH + safezoneY;
	w = safezoneW;
	h = 0.0322 * safezoneH;

    colorBackground[] = COLOR_GREY_HARD;
    colorStripBackground[] = COLOR_GREY_HARD;

    // config approach to menu strip offers more functionality than SQF

    class Items {

        items[] = {"OrbatCreator","FactionEditor","UnitEditor","GroupEditor","Export","Help"};

        class Default {
            enable = 0;
            text = "Empty";
        };

        class Separator {



        };

        class OrbatCreator {

            text = "ORBAT Creator";
            items[] = {"OrbatCreator_Close"};

        };

        class OrbatCreator_Close : menuStrip_button_action {

            text = "Close";
            data = "orbatCreatorClose";

        };

        class FactionEditor {

            text = "Faction Editor";
            items[] = {"FactionEditor_Open"};

        };

        class FactionEditor_Open : menuStrip_button_action {

            text = "Open";
            data = "factionEditorOpen";
            opensNewWindow = 1;

        };

        class UnitEditor {

            text = "Unit Editor";
            items[] = {"UnitEditor_Open"};

        };

        class UnitEditor_Open : menuStrip_button_action {

            text = "Open";
            data = "unitEditorOpen";
            opensNewWindow = 1;

        };

        class GroupEditor {

            text = "Group Editor";
            items[] = {"GroupEditor_Open"};

        };

        class GroupEditor_Open : menuStrip_button_action {

            text = "Open";
            data = "groupEditorOpen";
            opensNewWindow = 1;

        };

        class Export {

            text = "Export";
            items[] = {"Export_Faction","Export_Crates","Export_Units","Export_Groups","Export_Full","Export_FullWrite","Export_CfgPatches"}; // Separator, Export_Settings

        };

        class Export_Faction : menuStrip_button_action {

            text = "Faction";
            data = "exportFaction";

        };

        class Export_Crates : menuStrip_button_action {

            text = "Crates";
            data = "exportCrates";

        };

        class Export_Units {

            text = "Units";
            items[] = {"Export_Units_Selected","Export_Units_All","Separator","Export_Units_Classes"};

        };

        class Export_Groups {

            text = "Groups";
            items[] = {"Export_Groups_Selected","Export_Groups_All","Export_Groups_All_StaticData"};
            data = "exportGroups";

        };

        class Export_Full : menuStrip_button_action {

            text = "Full Faction";
            data = "exportFull";

        };

        class Export_FullWrite : menuStrip_button_action {

            text = "Full Faction (To File)";
            data = "exportFullWrite";

        };

        class Export_CfgPatches : menuStrip_button_action {

            text = "CfgPatches";
            data = "exportCfgPatches";

        };

        class Export_Settings : menuStrip_button_action {

            text = "Settings";
            data = "exportSettings";

        };

        class Export_Units_Selected : menuStrip_button_action {

            text = "Selected Units";
            data = "exportUnitsSelected";

        };

        class Export_Units_All : menuStrip_button_action {

            text = "All Units";
            data = "exportUnitsAll";

        };

        class Export_Units_Classes : menuStrip_button_action {

            text = "Unit Classenames";
            data = "exportUnitsClasses";

        };

        class Export_Groups_Selected : menuStrip_button_action {

            text = "Selected Groups";
            data = "exportGroupsSelected";

        };

        class Export_Groups_All : menuStrip_button_action {

            text = "All Groups";
            data = "exportGroupsAll";

        };

        class Export_Groups_All_StaticData : menuStrip_button_action {

            text = "All Groups (StaticData - Advanced Users Only)";
            data = "exportGroupsAllStaticData";

        };

        class Help {

            text = "Help";
            items[] = {"Help_Documentation"};

        };

        class Help_Documentation {

            text = "Documentation";
            opensNewWindow = 1;
            picture = "\a3\3DEN\Data\Controls\ctrlMenu\link_ca.paa";
            weblink = "http://alivemod.com/wiki/index.php/ORBAT_Tool";

        };

    };

};



class orbatCreator_common_popup_header : orbatCreator_RscText {
	idc = 7031;

	text = "";
	x = 0.266667 * safezoneW + safezoneX;
	y = 0.122 * safezoneH + safezoneY;
	w = 0.466667 * safezoneW;
	h = 0.028 * safezoneH;
    sizeEx = BASE_SIZE_TEXT * 0.9;
	colorBackground[] = COLOR_ARMA_BG;
};

class orbatCreator_common_popup_background : orbatCreator_RscText {
	idc = 7032;

	text = "";
	x = 0.266667 * safezoneW + safezoneX;
	y = 0.15 * safezoneH + safezoneY;
	w = 0.466667 * safezoneW;
	h = 0.728 * safezoneH;
	colorBackground[] = COLOR_GREY_HARD;
};

class orbatCreator_common_popup_controlsGroup : orbatCreator_RscControlsGroup {
    idc = 7033;
	x = 0.266521 * safezoneW + safezoneX;
	y = 0.15 * safezoneH + safezoneY;
	w = 0.466667 * safezoneW;
	h = 0.728 * safezoneH;
};

class orbatCreator_common_popup_footer : orbatCreator_RscText {
	idc = 7036;
	x = 0.266667 * safezoneW + safezoneX;
	y = 0.878 * safezoneH + safezoneY;
	w = 0.466667 * safezoneW;
	h = 0.049 * safezoneH;
	colorBackground[] = COLOR_GREY_DARK_HARD;
};

class orbatCreator_common_popup_context : orbatCreator_RscStructuredText {
	idc = 7037;
	x = 0.273958 * safezoneW + safezoneX;
	y = 0.885 * safezoneH + safezoneY;
	w = 0.25 * safezoneW;
	h = 0.035 * safezoneH;
    size = BASE_SIZE_TEXT * 0.7;
	colorBackground[] = COLOR_BLACK(0);
};

class orbatCreator_common_popup_ok: orbatCreator_ctrlButtonOk {
	idc = 7038;

	text = "OK";
	x = 0.54375 * safezoneW + safezoneX;
	y = 0.8878 * safezoneH + safezoneY;
	w = 0.0875 * safezoneW;
	h = 0.028 * safezoneH;
};

class orbatCreator_common_popup_cancel: orbatCreator_ctrlButtonCancel {
	idc = 7039;

	text = "Cancel";
    action = "closeDialog 0";
	x = 0.638542 * safezoneW + safezoneX;
	y = 0.8878 * safezoneH + safezoneY;
	w = 0.0875 * safezoneW;
	h = 0.028 * safezoneH;
};

class orbatCreator_common_popup_attribute_title : orbatCreator_RscText {
	colorText[] = COLOR_GREY_TITLE_HARD;
    sizeEx = BASE_SIZE_TEXT * 0.9;
};

class orbatCreator_common_popup_attribute_subtitle : orbatCreator_common_popup_attribute_title {
    style = 0x01;
    colorText[] = COLOR_WHITE_HARD;
};