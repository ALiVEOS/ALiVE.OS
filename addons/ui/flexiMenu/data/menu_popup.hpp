#include "\x\alive\addons\ui\script_component.hpp"

#define _eval_image(_param) __EVAL(format ["%1\data\popup\%2.paa", _flexiMenu_path, ##_param])

#define _SX (safeZoneX+safeZoneW/2) // screen centre x
#define _SY (safeZoneY+safeZoneH/2) // screen centre y
#define _BW 0.20*safeZoneW // button width
#define _BH 0.033*safeZoneH // button height
#define _gapH 0.01*safeZoneH
#define _buttonsBeforeCenter 7 // buttons above screen centre, allowing menu to appear centred.
#define _captionColorBG 1, 1, 1 // BIS mid green (button over colour)
#define _captionColorFG 1, 1, 1 // BIS greenish text
#define _captionHgt 0.75
#define GUI_FONT_NORMAL	PuristaLight

class alive_flexiMenu_rscPopup { //: _flexiMenu_rscRose
	idd = -1; //_flexiMenu_IDD;
	movingEnable = 0;
	//onLoad = uiNamespace setVariable ['%1', _this select 0], QUOTE(GVAR(display));
	//onUnload = uiNamespace setVariable ['%1', displayNull], QUOTE(GVAR(display));

	onLoad = "with uiNamespace do {alive_ui_display = _this select 0}; (_this select 0) call alive_fFlexiMenu_keySpoof;";
	onUnload = "with uiNamespace do {alive_ui_display = displayNull};";
	class controlsBackground {};
	class objects {};

	flexiMenu_primaryMenuControlWidth = _BW;
	flexiMenu_subMenuControlWidth = _BW;
	flexiMenu_subMenuCaptionWidth = _BW;

//class listButton; // external ref
//#include "common_listClass.hpp"

	class listButton: _flexiMenu_RscShortcutButton {
		x = _SX-_BW;
		y = safeZoneY+0.30*safeZoneH;
		w = 0; //_BW; // hide initially
		h = _BH;
		sizeEx = _BH;
		size = _BH*0.75;

		color[] = {1, 1, 1, 1};
		color2[] = {1, 1, 1, 1}; //{1, 1, 1, 0.4};
		colorBackground[] = {1, 1, 1, 1};
		colorbackground2[] = {1, 1, 1, 0.4}; //{1, 1, 1, 0.4};
		colorDisabled[] = {0.5, 0.5, 0.5, 0.4};
		class TextPos {
			left = 0.02;
			top = 0.005;
			right = 0.02;
			bottom = 0.005;
		};
		class Attributes {
			font = GUI_FONT_NORMAL;
			color = "#FF0000";
			align = "left";
		};
		animTextureNormal = "x\alive\addons\ui\flexiMenu\data\popup\normal.paa";
		animTextureDisabled = "x\alive\addons\ui\flexiMenu\data\popup\disabled.paa";
		animTextureOver = "x\alive\addons\ui\flexiMenu\data\popup\over.paa";
		animTextureFocused = "x\alive\addons\ui\flexiMenu\data\popup\focused.paa";
		animTexturePressed = "x\alive\addons\ui\flexiMenu\data\popup\down.paa";
		animTextureDefault = "x\alive\addons\ui\flexiMenu\data\popup\default.paa";
		animTextureNoShortcut = "x\alive\addons\ui\flexiMenu\data\popup\normal.paa";
	};
	//---------------------------------
	class controls {
		class caption: rscText {
			idc = _flexiMenu_IDC_menuDesc;
			x = _SX-_BW;
			y = safeZoneY+0.30*safeZoneH-_BH*_captionHgt;
			w = _BW;
			h = _BH*_captionHgt;
			sizeEx = _BH*_captionHgt;
			color[] = {1, 1, 1, 1};
			colorBackground[] = {0, 0, 0, 0.7};
			text = "";
		};

#define ExpandMacro_RowControls(ID) \
	class button##ID: listButton\
	{\
		idc = __EVAL(_flexiMenu_IDC);\
		__EXEC(_flexiMenu_IDC = _flexiMenu_IDC+1);\
		y = safeZoneY+0.30*safeZoneH+##ID*_BH;\
	}

		__EXEC(_flexiMenu_IDC = _flexiMenu_baseIDC_button);
		ExpandMacro_RowControls(00);
		ExpandMacro_RowControls(01);
		ExpandMacro_RowControls(02);
		ExpandMacro_RowControls(03);
		ExpandMacro_RowControls(04);
		ExpandMacro_RowControls(05);
		ExpandMacro_RowControls(06);
		ExpandMacro_RowControls(07);
		ExpandMacro_RowControls(08);
		ExpandMacro_RowControls(09);
		ExpandMacro_RowControls(10);
		ExpandMacro_RowControls(11);
		ExpandMacro_RowControls(12);
		ExpandMacro_RowControls(13);
		ExpandMacro_RowControls(14);
		ExpandMacro_RowControls(15);
		ExpandMacro_RowControls(16);
		ExpandMacro_RowControls(17);
		ExpandMacro_RowControls(18);
		ExpandMacro_RowControls(19);
		//-----------------------
		class caption2: caption {
			idc = _flexiMenu_IDC_listMenuDesc;
			x = _SX;
			y = safeZoneY+0.30*safeZoneH+_BH-_BH*_captionHgt;
			w = 0; //flexiMenu_subMenuCaptionWidth; // hide initially
		};

//#include "common_listControls.hpp"
#define ExpandMacro_ListControls(ID)\
	class listButton##ID: listButton\
	{\
		idc = __EVAL(_flexiMenu_IDC);\
		__EXEC(_flexiMenu_IDC = _flexiMenu_IDC+1);\
		x = _SX;\
		y = safeZoneY+0.30*safeZoneH+_BH+##ID*_BH;\
	}

		__EXEC(_flexiMenu_IDC = _flexiMenu_baseIDC_listButton);
		ExpandMacro_ListControls(00);
		ExpandMacro_ListControls(01);
		ExpandMacro_ListControls(02);
		ExpandMacro_ListControls(03);
		ExpandMacro_ListControls(04);
		ExpandMacro_ListControls(05);
		ExpandMacro_ListControls(06);
		ExpandMacro_ListControls(07);
		ExpandMacro_ListControls(08);
		ExpandMacro_ListControls(09);
		ExpandMacro_ListControls(10);
		ExpandMacro_ListControls(11);
		ExpandMacro_ListControls(12);
		ExpandMacro_ListControls(13);
		ExpandMacro_ListControls(14);
		ExpandMacro_ListControls(15);
		ExpandMacro_ListControls(16);
		ExpandMacro_ListControls(17);
		ExpandMacro_ListControls(18);
		ExpandMacro_ListControls(19);
	};
};
