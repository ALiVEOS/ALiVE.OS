#define GUI_GRID_X  (0)
#define GUI_GRID_Y  (0)
#define GUI_GRID_W  (0.025)
#define GUI_GRID_H  (0.04)
#define GUI_GRID_WAbs (1)
#define GUI_GRID_HAbs (1)

class GMTablet_RscBackground
{
	idc = -1; 
	type = 0;
	style = 128;
	colorbackground[] = {0,0,0,1};
	colorText[] = {0,0,0,0};
	font = "PuristaMedium";
	sizeEx = 0;
	moving = 0;
	shadow =0;
	x = "(safeZoneX + (safeZoneW / 1.8))"; 
	y = "(safeZoneY + (safeZoneH / 3.25))"; 
	w = "(safeZoneW / 3)";
	h = "(safeZoneH / 2)";
};

class GMTablet_RscEdit
{
	idc = -1;
	type = 2;
	style = 0x00;
	x = "1";
	y = "1";
	w = "safeZoneW / 25";
	h = "safeZoneH / 30";
	sizeEx = 0.03;
	font = "PuristaMedium";
	text = "";
	colorText[] = {1,1,1,1};
	autocomplete = 0;
	colorSelection[] = {0,0,0,1};
	colorDisabled[] = {};
};

class GMTablet_RscText
{ 
	idc = -1; 
	type = 13; 
	style = 0x00;
	colorBackground[] = { 0, 0, 0, 0 };
	size = "((safeZoneW / 75) + (safeZoneH / 225))";
	x = "safeZoneX + (safeZoneW / 6)"; 
	y = "safeZoneY + (safeZoneH / 6)"; 
	w = "safeZoneW / 5"; 
	h = "safeZoneH / 10";
	text = "SUPPORT MENU";
	class Attributes 
	{ 
		font = "PuristaMedium"; 
		color = "#C0C0C0"; 
		align = "center"; 
		valign = "middle"; 
		shadow = true; 
		shadowColor = "#000000";
	};
};

class GMTablet_RscSlider
{ 
	idc = -1;
	type = 43;
	style = 0x400 + 0x10;
	x = "safeZoneX + (safeZoneW / 5.6)";
	y = "safeZoneY + (safeZoneH / 1.6)";
	w = "safeZoneW / 5.5";
	h = "safeZoneH / 40";
	color[] = {1, 1, 1, 0.4};
	colorActive[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.2};
	arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
};

class GMTablet_RscButton
{
	idc = -1;
	type = 16;
	style = 0x00;
	default = 0;
	shadow = 2;
	x = "safeZoneX + (safeZoneW / 5)";
	y = "safeZoneY + (safeZoneH / 1.525)";
	w = "(safeZoneW / 12.5)";
	h = "(safeZoneH / 20)";
	color[] = {0.8784, 0.8471, 0.651, 1.0};
	color2[] = {0.95, 0.95, 0.95, 1};
	colorBackground[] = {1, 1, 1, 1};
	colorbackground2[] = {1, 1, 1, 0.4};
	colorDisabled[] = {1, 1, 1, 0.25};
	periodFocus = 1.2;
	periodOver = 0.8;
	class HitZone
	{
        left = 0;
        top = 0;
        right = 0;
        bottom = 0;
	};
	class ShortcutPos
	{
		left = "safeZoneW / 100";
		top = "safeZoneH / 100";
		w = "safeZoneW / 100";
		h = "safeZoneH / 100";
	};
	class TextPos
	{
        left = "(((1 / 1.2) / 20) * 0.9) * (3/4)";
        top = "(      (     (1 / 1.2) / 20) -     (     (     (1 / 1.2) / 20) * 0.9)) / 2";
        right = 0.005;
        bottom = 0;
	};
	animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
    animTextureOver = "#(argb,8,8,3)color(1,1,1,0.5)";
    animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
	period = 0.4;
	font = "PuristaMedium";
	size = "(safeZoneW / 125) + (safeZoneH / 125)";
	text = "";
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	textureNoShortcut = "";
	action = "";
	class Attributes
	{
		font = "PuristaMedium";
		color = "#E5E5E5";
		align = "left";
		shadow = "true";
	};
	class AttributesImage
	{
		font = "PuristaMedium";
		color = "#E5E5E5";
		align = "left";
	};
};

class GMTablet_RscListNBoxArrowRight: GMTablet_RscButton
{
    idc = 1000;
    text = "<";
    borderSize = 0;
    colorShadow[] = {0,0,0,0};
};

class GMTablet_RscListNBoxArrowLeft: GMTablet_RscListNBoxArrowRight
{
    idc = 1001;
    text = ">";
};

class GMTablet_RscListNBox {
    style = ST_LEFT + LB_TEXTURES;
    type = 102;
    shadow = 0;
    font = "PuristaMedium";
    sizeEx = (safeZoneH / 100) + (safeZoneH / 100);
    x = "safeZoneX + (safeZoneW / 5)";
    y = "safeZoneY + (safeZoneH / 2.25)";
    w = "(safeZoneW / 10)";
    h = "(safeZoneH / 17)";
    color[] = {1, 1, 1, 1};
    colorText[] = {0.8,0.8,0.8,1};
    colorScrollbar[] = {0.95, 0.95, 0.95, 1};
    colorSelect[] = {0.023529, 0, 0.0313725, 1};
    colorSelect2[] = {0.023529, 0, 0.0313725, 1};
    colorSelectBackground[] = {0.173,0.173,0.173,1};
    colorSelectBackground2[] = {0.3,0.3,0.3,1};
    colorPicture[] = {1,1,1,1};
    colorPictureSelected[] = {1,1,1,1};
    colorPictureDisabled[] = {1,1,1,1};
    period = 1;
    colorBackground[] = {0,0,0,0};
    maxHistoryDelay = 1.0;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"",0.1,1};
    soundExpand[] = {"",0.1,1};
    soundCollapse[] = {"",0.1,1};
    colorDisabled[] = {0,0,0,0};
    class ListScrollBar
    {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
};

class GMTablet_RscListBox {
    type = 5;
    style = 0 + 0x10;
    font = "PuristaMedium";
    sizeEx = (safeZoneH / 100) + (safeZoneH / 100);
    x = "safeZoneX + (safeZoneW / 5)";
    y = "safeZoneY + (safeZoneH / 2.25)";
    w = "(safeZoneW / 10)";
    h = "(safeZoneH / 17)";
    color[] = {1, 1, 1, 1};
    colorText[] = {0.95, 0.95, 0.95, 1};
    colorScrollbar[] = {0.95, 0.95, 0.95, 1};
    colorSelect[] = {0.023529, 0, 0.0313725, 1};
    colorSelect2[] = {0.023529, 0, 0.0313725, 1};
    colorSelectBackground[] = {0.58, 0.1147, 0.1108, 1};
    colorSelectBackground2[] = {0.58, 0.1147, 0.1108, 1};
    period = 1;
    colorBackground[] = {0,0,0,0};
    maxHistoryDelay = 1.0;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"", 0.0, 1};
    soundExpand[] = {"", 0.0, 1};
    soundCollapse[] = {"", 0.0, 1};
    colorDisabled[] = {0,0,0,0};
    class ListScrollBar
    {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
};

class GMTablet_RscGUIListBox : GMTablet_RscListBox {
    color[] = {1, 1, 1, 1};
    colorText[] = {1, 1, 1, 0.75};
    colorScrollbar[] = {0.023529, 0, 0.0313725, 1};
    colorSelect[] = {0.694,0.78,0.624,1};
    colorSelect2[] = {0.694,0.78,0.624,1};
    colorSelectBackground[] = {0.333,0.333,0.333,1};
    colorSelectBackground2[] = {0.333,0.333,0.333,1};
    period = 0;
    sizeEx = (safeZoneH / 100) + (safeZoneH / 100);
    class ListScrollBar
    {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
};

class GMTablet_RscComboBox
{
    access = 0;
    type = 4;
    style = 0;
    colorSelect[] = {0.023529,0,0.0313725,1};
    colorText[] = {0.023529,0,0.0313725,1};
    colorBackground[] = {0.95,0.95,0.95,1};
    colorScrollbar[] = {0.023529,0,0.0313725,1};
    soundSelect[] = {"",0.1,1};
    soundExpand[] = {"",0.1,1};
    soundCollapse[] = {"",0.1,1};
    maxHistoryDelay = 1;
    class ComboScrollBar
    {
        color[] = {1,1,1,0.6};
        colorActive[] = {1,1,1,1};
        colorDisabled[] = {1,1,1,0.3};
        shadow = 0;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
    x = "safeZoneX + (safeZoneW / 8)";
    y = "safeZoneY + (safeZoneH / 5)";
    w = "(safeZoneW / 10)";
    h = "(safeZoneH / 20)";
    shadow = 0;
    colorSelectBackground[] = {0.8784,0.8471,0.651,1};
    arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
    arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
    wholeHeight = 0.45;
    color[] = {0,0,0,0.6};
    colorActive[] = {0,0,0,1};
    colorDisabled[] = {0,0,0,0.3};
    font = "PuristaMedium";
    sizeEx = "(safeZoneH / 100) + (safeZoneH / 100)";
};

class GMTablet_RscMap
{	
    access = 0;
    alphaFadeEndScale = 0.4;
    alphaFadeStartScale = 0.35;
    colorBackground[] = {0.969,0.957,0.949,1};
    colorCountlines[] = {0.572,0.354,0.188,0.25};
    colorCountlinesWater[] = {0.491,0.577,0.702,0.3};
    colorForest[] = {0.624,0.78,0.388,0.5};
    colorForestBorder[] = {0,0,0,0};
    colorGrid[] = {0.1,0.1,0.1,0.6};
    colorGridMap[] = {0.1,0.1,0.1,0.6};
    colorInactive[] = {1,1,1,0.5};
    colorLevels[] = {0.286,0.177,0.094,0.5};
    colorMainCountlines[] = {0.572,0.354,0.188,0.5};
    colorMainCountlinesWater[] = {0.491,0.577,0.702,0.6};
    colorMainRoads[] = {0.9,0.5,0.3,1};
    colorMainRoadsFill[] = {1,0.6,0.4,1};
    colorNames[] = {0.1,0.1,0.1,0.9};
    colorOutside[] = {0,0,0,1};
    colorPowerLines[] = {0.1,0.1,0.1,1};
    colorRailWay[] = {0.8,0.2,0,1};
    colorRoads[] = {0.7,0.7,0.7,1};
    colorRoadsFill[] = {1,1,1,1};
    colorRocks[] = {0,0,0,0.3};
    colorRocksBorder[] = {0,0,0,0};
    colorSea[] = {0.467,0.631,0.851,0.5};
    colorText[] = {0,0,0,1};
    colorTracks[] = {0.84,0.76,0.65,0.15};
    colorTracksFill[] = {0.84,0.76,0.65,1};
    font = "TahomaB";
    fontGrid = "TahomaB";
    fontInfo = "PuristaMedium";
    fontLabel = "PuristaMedium";
    fontLevel = "TahomaB";
    fontNames = "PuristaMedium";
    fontUnits = "TahomaB";
    maxSatelliteAlpha = 0.85;
    moveOnEdges = 1;
    ptsPerSquareSea = 8;
    ptsPerSquareTxt = 10;
    ptsPerSquareCLn = 10;
    ptsPerSquareExp = 10;
    ptsPerSquareCost = 10;
    ptsPerSquareFor = "6.0f";
    ptsPerSquareForEdge = "15.0f";
    ptsPerSquareRoad = "3f";
    ptsPerSquareObj = 15;
    scaleDefault = 0.16;
    scaleMax = 1;
    scaleMin = 0.001;
    shadow = 0;
    showCountourInterval = 0;
    sizeEx = 0.04;
    sizeExGrid = 0.02;
    sizeExInfo = "(     (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
    sizeExLabel = "(      (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
    sizeExLevel = 0.02;
    sizeExNames = "(      (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8) * 2";
    sizeExUnits = "(      (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
    stickX[] = {0.2,["Gamma",1,1.5]};
    stickY[] = {0.2,["Gamma",1,1.5]};
    style = 48;
    text = "#(argb,8,8,3)color(1,1,1,1)";
    type = 101;
    x = "(safeZoneX + (safeZoneW / 1.67))";
    y = "(safeZoneY + (safeZoneH / 2.49))";
    w = "(safeZoneW / 4.05)";
    h = "(safeZoneH / 4.2)";
	class ActiveMarker
    {
        color[] = {0.3,0.1,0.9,1};
        size = 50;
    };
    class Bunker
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        importance = "1.5 * 14 * 0.05";
        size = 14;
    };
    class Bush
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0.45,0.64,0.33,0.4};
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        importance = "0.2 * 14 * 0.05 * 0.05";
        size = "14/2";
    };
    class BusStop
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
        importance = 1;
        size = 24;
    };
    class Chapel
    {
        coefMax = 4;
        coefMin = 0.85;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa";
        importance = 1;
        size = 24;
    };
    class Church
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
        importance = 1;
        size = 24;
    };
    class Command
    {
        coefMax = 1;
        coefMin = 1;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        importance =1;
        size = 18;
    };
    class Cross
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa";
        importance = 1;
        size = 24;
    };
    class CustomMark
    {
        coefMax = 1;
        coefMin = 1;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\custommark_ca.paa";
        importance = 1;
        size = 24;
    };
    class Fortress
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        importance = "2 * 16 * 0.05";
        size = 16;
    };
    class Fountain
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
        importance = "1 * 12 * 0.05";
        size = 11;
    };
    class Fuelstation
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_CA.paa";
        importance = 1;
        size = 24;
    };
    class Hospital
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\hospital_CA.paa";
        importance = 1;
        size = 24;
    };
    class Legend
    {
        color[] = {0,0,0,1};
        colorBackground[] = {1,1,1,0.5};
        font = "PuristaMedium";
        h = "3.5 *          (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        sizeEx = "(     (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
        w = "10 *           (     ((safezoneW / safezoneH) min 1.2) / 40)";
        x = "SafeZoneX +          (     ((safezoneW / safezoneH) min 1.2) / 40)";
        y = "SafeZoneY + safezoneH - 4.5 *          (     (     ((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
    };
    class Lighthouse
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_CA.paa";
        importance = 1;
        size = 24;
    };
    class power
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\power_CA.paa";
        importance = 1;
        size = 24;
    };
    class powersolar
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\powersolar_CA.paa";
        importance = 1;
        size = 24;
    };
    class powerwind
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\powerwind_CA.paa";
        importance = 1;
        size = 24;
    };
    class powerwave
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\powerwave_CA.paa";
        importance = 1;
        size = 24;
    };
    class Quay
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\quay_CA.paa";
        importance = 1;
        size = 24;
    };
    class Rock
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0.1,0.1,0.1,0.8};
        icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
        importance = "0.5 * 12 * 0.05";
        size = 12;
    };
    class Ruin
    {
        coefMax = 4;
        coefMin = 1;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
        importance = "1.2 * 16 * 0.05";
        size = 16;
    };
    class shipwreck
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\shipwreck_CA.paa";
        importance = 1;
        size = 24;
    };
    class SmallTree
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0.45,0.64,0.33,0.4};
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        importance = "0.6 * 12 * 0.05";
        size = 12;
    };
    class Stack
    {
        coefMax = 4;
        coefMin = 0.9;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
        importance = "2 * 16 * 0.05";
        size = 20;
    };
    class Task
    {
        coefMax = 1;
        coefMin = 1;
        color[] = {"(profilenamespace getvariable ['IGUI_TEXT_RGB_R',0])","(profilenamespace getvariable ['IGUI_TEXT_RGB_G',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_B',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_A',0.8])"};
        colorCanceled[] = {0.7,0.7,0.7,1};
        colorCreated[] = {1,1,1,1};
        colorDone[] = {0.7,1,0.3,1};
        colorFailed[] = {1,0.3,0.2,1};
        icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
        iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
        iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
        iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
        iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
        importance = 1;
        size = 27;
    };
    class Tourism
    {
        coefMax = 4;
        coefMin = 0.7;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
        importance = "1 * 16 * 0.05";
        size = 16;
    };
    class Transmitter
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
        importance = 1;
        size = 24;
    };
    class Tree
    {
        coefMax = 4;
        coefMin = 0.25;
        color[] = {0.45,0.64,0.33,0.4};
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        importance = "0.9 * 16 * 0.05";
        size = 12;
    };
    class ViewTower
    {
        coefMax = 4;
        coefMin = 0.5;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
        importance = "2.5 * 16 * 0.05";
        size = 16;
    };
    class Watertower
    {
        coefMax = 1;
        coefMin = 0.85;
        color[] = {1,1,1,1};
        icon = "\A3\ui_f\data\map\mapcontrol\watertower_CA.paa";
        importance = 1;
        size = 24;
    };
    class Waypoint
    {
        coefMax = 1;
        coefMin = 1;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        importance = 1;
        size = 24;
    };
    class WaypointCompleted
    {
        coefMax = 1;
        coefMin = 1;
        color[] = {0,0,0,1};
        icon = "\A3\ui_f\data\map\mapcontrol\waypointCompleted_ca.paa";
        importance = 1;
        size = 24;
    };
};

class RscPicture
{
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    fixedWidth = 0;
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    font = "PuristaMedium";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};