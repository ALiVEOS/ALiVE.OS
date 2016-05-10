#include  <\x\alive\addons\sys_viewdistance\commonDefs.hpp>
#include  <\x\alive\addons\sys_viewdistance\rscCommon.hpp>

class vdist_Slider: RscSlider {
};

#define X_MOD 52
#define X_MODB 51.5
#define Y_MOD 10
#define SLIDER_START -19
#define SLIDER_INTERVAL 4
#define SLIDER_TITLE_SPACE 1.3
#define GUI_GRID_WAbs			((safezoneW / safezoneH) min 1.2)
#define GUI_GRID_HAbs			(GUI_GRID_WAbs / 1.2)
#define GUI_GRID_W			(GUI_GRID_WAbs / 40)
#define GUI_GRID_H			(GUI_GRID_HAbs / 25)
#define GUI_GRID_X			(safezoneX)
#define GUI_GRID_Y			(safezoneY + safezoneH - GUI_GRID_HAbs)

class vdist_dialog {
	idd = 10568;movingEnable = 1;enableSimulation = 1;enableDisplay = 1;

	onLoad = "vdist_dialog = _this; disableSerialization";

	class controls {
		class vdistback: RscPicture {
			idc = -1;text = "x\alive\addons\sys_viewdistance\ALiVE_Intface_1.paa";x = 0.394859 * safezoneW + safezoneX;y = 0.130369 * safezoneH + safezoneY;w = 0.204097 * safezoneW;h = 0.798068 * safezoneH;moving = 0;
			colorBackground[] = { 0, 0, 0, 0 };
		};
		class vd_text: RscText {
			idc = 1012;text = "$STR_ALIVE_VDIST";x = 0.452996 * safezoneW + safezoneX;y = 0.334787 * safezoneH + safezoneY;w = 0.0804017 * safezoneW;h = 0.0280024 * safezoneH;
		};
		class vd_amnt: RscText {
			idc = 10091;text = "";style = 2; //1 2 3...176
			x = 0.454233 * safezoneW + safezoneX;y = 0.368389 * safezoneH + safezoneY;w = 0.0742169 * safezoneW;h = 0.0280024 * safezoneH;
		};
		class vd_slider: RscSlider // view distance slider
		{
			idc = 1912;x = 0.434442 * safezoneW + safezoneX;y = 0.413192 * safezoneH + safezoneY;w = 0.11751 * safezoneW;h = 0.0280024 * safezoneH;
		};
		class td_text: RscText {
			idc = 1013;text = "$STR_ALIVE_TGRID";x = 0.454233 * safezoneW + safezoneX;y = 0.457996 * safezoneH + safezoneY;w = 0.0742169 * safezoneW;h = 0.0280024 * safezoneH;
		};
		class td_amnt: RscText {
			idc = 10093;text = "";style = 2; //1 2 3...176
			x = 0.454233 * safezoneW + safezoneX;y = 0.488799 * safezoneH + safezoneY;w = 0.0742169 * safezoneW;h = 0.0280024 * safezoneH;
		};
		class td_slider: RscSlider // view distance slider
		{
			idc = 1913;x = 0.435679 * safezoneW + safezoneX;y = 0.539204 * safezoneH + safezoneY;w = 0.11751 * safezoneW;h = 0.0280024 * safezoneH;
		};
	};
};
