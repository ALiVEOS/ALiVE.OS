// ====================================================================================
// DEFINES
#define CT_STRUCTURED_TEXT	13
#define ST_LEFT				0
// ====================================================================================


///////////////////////////////////////////////////////////////////////////
/// Base Dialog Classes
///////////////////////////////////////////////////////////////////////////

class RscTUP_IEDButton
{
	access = 0;
	type = 1;
	text = "";
	colorText[] = {0.8784,0.8471,0.651,1};
	colorDisabled[] = {0.4,0.4,0.4,1};
	colorBackground[] = {1,0.537,0,0.5};
	colorBackgroundDisabled[] = {0.95,0.95,0.95,1};
	colorBackgroundActive[] = {1,0.537,0,1};
	colorFocused[] = {0.4,0.6,0.3,1};
	colorShadow[] = {0.023529,0,0.0313725,1};
	colorBorder[] = {0.023529,0,0.0313725,1};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	style = 2;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	shadow = 2;
	font = "PuristaLight";
	sizeEx = 0.03921;
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	borderSize = 0;
};


class RscTUP_IEDStructuredText
{
	access = 0;
	type = 13;
	idc = -1;
	style = 0;
	colorText[] = {0.8784,0.8471,0.651,1};
	class Attributes
	{
		font = "PuristaLight";
		color = "#e0d8a6";
		align = "center";
		shadow = 1;
	};
	x = 0;
	y = 0;
	h = 0.035;
	w = 0.1;
	text = "";
	size = 0.03921;
	shadow = 2;
};


class RscTUP_IEDText
{
	type = 0;
	idc = -1;
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	style = 0x100;
	font = PuristaLight;
	SizeEx = 0.03921;
	colorText[] = {1,1,1,1};
	colorBackground[] = {0, 0, 0, 0};
	linespacing = 1;
};


///////////////////////////////////////////////////////////////////////////
/// TUP_IED Class Dialogs
///////////////////////////////////////////////////////////////////////////


class tup_ied_DisarmPrompt
{

	idd = 1600;
	movingEnable = 0;
	enableSimulation = 1;

	class Controls
	{
				class iedTextbox: RscTUP_IEDStructuredText
				{
					idc = 1100;
					text = "The IED device appears to have a detonation wiring configuration that is new to you. Two wires connect to the detonator, do you cut the red wire or the blue wire";
					x = 0.335938 * safezoneW + safezoneX;
					y = 0.419183 * safezoneH + safezoneY;
					w = 0.329693 * safezoneW;
					h = 0.06 * safezoneH;
					colorText[] = {0.4,0.6,0.3,1};
					colorBackground[] = {-1,-1,-1,0};
					colorBackgroundActive[] = {-1,-1,-1,0};
				};
				class iedButtonYes: RscTUP_IEDButton
				{
					idc = 1600;
					text = "Red Wire";
					x = 0.393943 * safezoneW + safezoneX;
					y = 0.483572 * safezoneH + safezoneY;
					w = 0.0699643 * safezoneW;
					h = 0.0352834 * safezoneH;
					colorText[] = {0.8,0.7,0.5,1};
					colorBackground[] = {0.4,0.6,0.3,1};
					colorBackgroundActive[] = {0.4,0.7,0.3,1};
					onButtonClick = "tup_ied_wire = 'red'; (ctrlParent (_this select 0)) displayRemoveEventHandler [""KeyDown"", noesckey];   ((ctrlParent (_this select 0)) closeDisplay 1600);";
				};
				class ied_ButtonNo: RscTUP_IEDButton
				{
					idc = 1601;
					text = "Blue Wire";
					x = 0.537661 * safezoneW + safezoneX;
					y = 0.482259 * safezoneH + safezoneY;
					w = 0.0699643 * safezoneW;
					h = 0.0352834 * safezoneH;
					colorText[] = {0.8,0.7,0.5,1};
					colorBackground[] = {0.4,0.6,0.3,1};
					colorBackgroundActive[] = {0.4,0.7,0.3,1};
					onButtonClick = "tup_ied_wire = 'blue'; (ctrlParent (_this select 0)) displayRemoveEventHandler [""KeyDown"", noesckey]; ((ctrlParent (_this select 0)) closeDisplay 1600);";
				};
	};

};


