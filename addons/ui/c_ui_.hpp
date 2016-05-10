/* ----------------------------------------------------------------------------
Header: Columns UI
Description:
	A set of default classes for quick/easy dialog construction.
Author:
	Rommel
---------------------------------------------------------------------------- */

#define CUI_Colours_Darker				73/256, 73/256, 73/256
#define CUI_Colours_Dark				39/256, 46/256, 38/256
#define CUI_Colours_Normal				59/256, 79/256, 51/256
#define CUI_Colours_Light				93/256, 117/256, 93/256
#define CUI_Colours_Lighter				204/256, 255/256, 151/256

//-----------------------------------------------------------------------------
#define CUI_Colours_DialogBackground	CUI_Colours_Dark
#define CUI_Colours_DialogText			CUI_Colours_Normal

#define CUI_Colours_WindowBackground	CUI_Colours_Dark
#define CUI_Colours_WindowText			CUI_Colours_Lighter

#define CUI_Colours_CaptionBackground	CUI_Colours_Light
#define CUI_Colours_CaptionText			CUI_Colours_Lighter

//-----------------------------------------------------------------------------

#define safeX	(safeZoneX * 0.9)
#define safeY	(safeZoneY * 0.9)
#define safeH	(safeZoneH * 0.9)
#define safeW	(safeZoneW * 0.9)

#define safeCX	(safeX + safeW/2)
#define safeCY	(safeY + safeH/2)

//-----------------------------------------------------------------------------
//Rows

#ifndef CUI_Rows
#define CUI_Rows 42
#endif

#define CUI_Row_H	((safeH / CUI_Rows) / 0.8)
#define CUI_Row_Y(integer)	(safeY + ((integer) * CUI_Row_H))
#define CUI_Row_DY(int1,int2)	(((int2) - (int1)) * CUI_Row_H)

//-----------------------------------------------------------------------------
//Boxes

#ifndef CUI_Boxes
#define CUI_Boxes 4
#endif

#define CUI_Box_H	(CUI_Row_H * (CUI_Rows / CUI_Boxes))
#define CUI_Box_W	(safeW / CUI_Boxes)

#define CUI_Box_X(integer)	(safeX + ((integer) * CUI_Box_W))
#define CUI_Box_Y(integer)	(safeY + ((integer) * CUI_Box_H))

#define CUI_Box_Row(int1,int2)	(CUI_Box_Y(int1) + ((int2) * CUI_Row_H))

#define CUI_Box_Rows	(CUI_Box_H / CUI_Row_H)

//-----------------------------------------------------------------------------
//Dialogs

class CUI_Frame	{
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Y(0);
	w = CUI_Box_W; h = CUI_Box_H;
	
	type = 0; style = 0x00;
	sizeEx = 0.032;	font = "Zeppelin32";
	
	colorBackground[] = {CUI_Colours_DialogBackground, 3/4};
	colorText[] = {0,0,0,0};
	text = "";
};

class CUI_Caption : CUI_Frame {
	h = CUI_Row_H;

	colorBackground[] = {CUI_Colours_CaptionBackground, 4/5};
	colorText[] = {CUI_Colours_CaptionText, 1};
};

class CUI_List {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_DY(0,5);
	
	type = 5; style = 0 + 0x10;
	sizeEx = 0.032;	font = "Zeppelin32";
	
	rowHeight = CUI_Row_H;
	wholeHeight = 5 * CUI_Row_H;
	
	color[] = {0,0.5,0,1};
	colorText[] = {CUI_Colours_WindowText, 1};
	colorBackground[] = {CUI_Colours_WindowBackground, 3/4};
	colorScrollbar[] = {0.95, 0.95, 0.95, 1};
	colorSelect[] = {CUI_Colours_DialogText, 1/2};
	colorSelect2[] = {0.95, 0.95, 0.95, 1};
	colorSelectBackground[] = {0,1,0,1};
	colorSelectBackground2[] = {0.6, 0.8392, 0.4706, 1.0};

	period = 0;
	
	soundSelect[] = {"", 0.0, 1};
	
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	maxHistoryDelay = 1.0;

	arrowFull = "\ca\ui\data\ui_arrow_top_active_ca.paa";
	arrowEmpty = "\ca\ui\data\ui_arrow_top_ca.paa";
	
	class ScrollBar	{
		color[] = {CUI_Colours_WindowText, 3/4};
		colorActive[] = {CUI_Colours_WindowText, 1};
		colorDisabled[] = {CUI_Colours_WindowText, 1/2};
		thumb = "\ca\ui\data\ui_scrollbar_thumb_ca.paa";
		arrowFull = "\ca\ui\data\ui_arrow_top_active_ca.paa";
		arrowEmpty = "\ca\ui\data\ui_arrow_top_ca.paa";
		border = "\ca\ui\data\ui_border_scroll_ca.paa";
	};
};

class CUI_Button {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 1; style = 0x02;
	sizeEx = 0.032;	font = "Zeppelin32";
	
	colorText[] = {CUI_Colours_WindowText, 1};
	colorFocused[] = {CUI_Colours_DialogBackground, 3/5};
	colorDisabled[] = {CUI_Colours_DialogBackground, 2/5};
	colorBackground[] = {CUI_Colours_DialogBackground, 4/5};
	colorBackgroundDisabled[] = {CUI_Colours_DialogBackground, 4/5};
	colorBackgroundActive[] = {CUI_Colours_DialogBackground, 5/5};
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	colorShadow[] = { 0, 0, 0, 0 };
	colorBorder[] = { 0, 0, 0, 0 };
	borderSize = 0;
	soundEnter[] = {"", 0, 1};
	soundPush[] = {"", 0.1, 1};
	soundClick[] = {"", 0, 1};
	soundEscape[] = {"", 0, 1};
};

class CUI_Combo {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 4; style = 0x00;
	sizeEx = 0.032;	font = "Zeppelin32";
	
	rowHeight = CUI_Row_H;
	wholeHeight = 5 * CUI_Row_H;

	color[] = {1,1,1,3/4};
	colorText[] = {CUI_Colours_WindowText, 3/5};
	colorBackground[] = {CUI_Colours_DialogBackground, 2/4};
	colorSelect[] = {CUI_Colours_WindowText, 1};
	colorSelectBackground[] = {CUI_Colours_DialogBackground, 3/4};
	soundSelect[] = {"", 0.0, 1};
	soundExpand[] = {"", 0.0, 1};
	soundCollapse[] = {"", 0.0, 1};
	
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	maxHistoryDelay = 1.0;
	
	arrowFull = "\ca\ui\data\ui_arrow_top_active_ca.paa";
	arrowEmpty = "\ca\ui\data\ui_arrow_top_ca.paa";
	
	class ScrollBar	{
		color[] = {CUI_Colours_WindowText, 3/4};
		colorActive[] = {CUI_Colours_WindowText, 1};
		colorDisabled[] = {CUI_Colours_WindowText, 1/2};
		thumb = "\ca\ui\data\ui_scrollbar_thumb_ca.paa";
		arrowFull = "\ca\ui\data\ui_arrow_top_active_ca.paa";
		arrowEmpty = "\ca\ui\data\ui_arrow_top_ca.paa";
		border = "\ca\ui\data\ui_border_scroll_ca.paa";
	};
};

class CUI_Edit {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	htmlControl = true;
	type = 2; style = 16;
	sizeEx = 0.028;	font = "BitStream";

	colorBackground[] = {CUI_Colours_DialogBackground, 4/5};
	colorText[] = {CUI_Colours_WindowText, 4/5};
	colorSelection[] = {0,0,0,1};

	autocomplete = false;
	text = "";
};

class CUI_Slider {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 3; style = 0x400;
	
	color[] = {CUI_Colours_WindowText, 4/5};
	coloractive[] = {CUI_Colours_WindowText, 1};
	onSliderPosChanged = "";
};

class CUI_Text {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 0; style = 0x00;
	sizeEx = 0.032;	font = "Zeppelin32";

	colorBackground[] = {0,0,0,0};
	colorText[] = {CUI_Colours_WindowText, 1};
};

class CUI_StructText {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 13; style = 0x00;
	size = 0.032;	font = "Zeppelin32";

	colorBackground[] = {0,0,0,0};
	colorText[] = {CUI_Colours_WindowText, 1};
};

class CUI_ControlGroup {
	idc = -1;
	x = CUI_Box_X(0); y = CUI_Box_Row(0,1);
	w = CUI_Box_W; h = CUI_Row_H;
	
	type = 15; style = 0x00;

	class VScrollbar {
		color[] = {1, 1, 1, 1};
		width = 0.021;
		autoScrollSpeed = -1;
		autoScrollDelay = 5;
		autoScrollRewind = 0;
	};
	class HScrollbar {
		color[] = {1, 1, 1, 1};
		height = 0.028;
	};
	class ScrollBar {
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "#(argb,8,8,3)color(1,1,1,1)";
		arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
		arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
		border = "#(argb,8,8,3)color(1,1,1,1)";
	};
	class controls {};
};