class Playermarker_RscStructuredText {
	type = 13;
	style = 0;
	x = 0;
	y = 0;
	h = 0.035;
	w = 0.1;
	text = "";
	size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorText[] = {1, 1, 1, 1.0};
	shadow = 1;
	class Attributes {
		font = "PuristaMedium";
		color = "#ffffff";
		align = "left";
		shadow = 1;
	};
};

class Playermarker_RscSlider_Color
{
	style = 1024;
	type = 43;
	shadow = 2;
	x = 0;
	y = 0;
	h = 0.029412;
	w = 0.400000;
	color[] = {1, 1, 1, 0.7};
	colorActive[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.500000};
	arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
	thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
};

class Playermarker_RscEdit {
	type = 2;
	style = 0x00 + 0xC0;
	font = "PuristaLight";
	shadow = 2;
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorBackground[] = {0, 0, 0, 1};
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	colorText[] = {0.95, 0.95, 0.95, 1};
	colorDisabled[] = {1, 1, 1, 0.25};
	autocomplete = 0;
	colorSelection[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 1};
	canModify = 1;
};

class Playermarker_RscText {
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	type = 0;
	style = 0x02;
	shadow = 1;
	colorShadow[] = {0, 0, 0, 0.5};
	font = "PuristaBold";
	SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	text = "";
	align = "center";
	colorText[] = {1, 1, 1, 1.0};
	colorBackground[] = {0, 0, 0, 0};
	linespacing = 1;
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	class Attributes {
    align = "center";
  };
};

class PlayerMarker_Settings
{
    idd = 56000;
    name= "PlayerMarker_Settings";
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground
    {
      class Titlebar: Playermarker_RscText
      {
      	idc = -1;
      	text = "Player Marker Settings"; //--- ToDo: Localize;
      	x = 0.304062 * safezoneW + safezoneX;
      	y = 0.269 * safezoneH + safezoneY;
      	w = 0.391875 * safezoneW;
      	h = 0.022 * safezoneH;
        onLoad = "(_this select 0) ctrlSetBackgroundColor [(profileNamespace getVariable ['GUI_BCG_RGB_R',0]),(profileNamespace getVariable ['GUI_BCG_RGB_G',1]),(profileNamespace getVariable ['GUI_BCG_RGB_B',0.05]),1]";
      	colorBackground[] = {-1,-1,-1,0};
      	tooltip = "All original files & images are © 2018 Asaayu."; //--- ToDo: Localize;
      };
      class BlackBackground: Playermarker_RscStructuredText
      {
      	idc = -1;
      	x = 0.304062 * safezoneW + safezoneX;
      	y = 0.291 * safezoneH + safezoneY;
      	w = 0.391875 * safezoneW;
      	h = 0.462 * safezoneH;
      	colorBackground[] = {0,0,0,0.5};
      };
    };

    class controls
    {
      class NameColor: Playermarker_RscText
      {
      	idc = 1105;
      	text = "Name Color"; //--- ToDo: Localize;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.544 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
      	tooltip = "Change the color of names"; //--- ToDo: Localize;
      };
      class NameRedColor: Playermarker_RscSlider_Color
      {
      	idc = 1901;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.577 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {1, 0, 0, 1};
        color[] = {1, 0, 0, 1};
        onSliderPosChanged = "playermarker_nameColor set [0,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_nameColor select 0) * 10)";
      	tooltip = "RED"; //--- ToDo: Localize;
      };
      class NameGreenColor: Playermarker_RscSlider_Color
      {
      	idc = 1902;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.61 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {0, 1, 0, 1};
        color[] = {0, 1, 0, 1};
        onSliderPosChanged = "playermarker_nameColor set [1,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_nameColor select 1) * 10)";
      	tooltip = "GREEN"; //--- ToDo: Localize;
      };
      class NameBlueColor: Playermarker_RscSlider_Color
      {
      	idc = 1903;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.643 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {0, 0, 1, 1};
        color[] = {0, 0, 1, 1};
        onSliderPosChanged = "playermarker_nameColor set [2,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_nameColor select 2) * 10)";
      	tooltip = "BLUE"; //--- ToDo: Localize;
      };
      class NameAlphaColor: Playermarker_RscSlider_Color
      {
      	idc = 1904;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.676 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {1, 1, 1, 1};
        color[] = {1, 1, 1, 1};
        onSliderPosChanged = "playermarker_nameColor set [3,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_nameColor select 3) * 10)";
      	tooltip = "ALPHA"; //--- ToDo: Localize;
      };
      class NameExampleColor: Playermarker_RscStructuredText
      {
      	idc = 1106;
      	text = ""; //--- ToDo: Localize;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.709 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.033 * safezoneH;
        onLoad = "(_this select 0) ctrlSetBackgroundColor playermarker_nameColor";
      	colorBackground[] = {-1,-1,-1,0};
      };
      class IconColor: Playermarker_RscText
      {
      	idc = 1107;
      	text = "Icon Color"; //--- ToDo: Localize;
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.544 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
      	tooltip = "Change the color of icons"; //--- ToDo: Localize;
      };
      class IconRedColor: Playermarker_RscSlider_Color
      {
      	idc = 1905;
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.577 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {1, 0, 0, 1};
        color[] = {1, 0, 0, 1};
        onSliderPosChanged = "playermarker_iconColor set [0,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_iconColor select 0) * 10)";
      	tooltip = "RED"; //--- ToDo: Localize;
      };
      class IconGreenColor: Playermarker_RscSlider_Color
      {
      	idc = 1906;
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.61 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {0, 1, 0, 1};
        color[] = {0, 1, 0, 1};
        onSliderPosChanged = "playermarker_iconColor set [1,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_iconColor select 1) * 10)";
      	tooltip = "GREEN"; //--- ToDo: Localize;
      };
      class IconBlueColor: Playermarker_RscSlider_Color
      {
      	idc = 1907;
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.643 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {0, 0, 1, 1};
        color[] = {0, 0, 1, 1};
        onSliderPosChanged = "playermarker_iconColor set [2,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_iconColor select 2) * 10)";
      	tooltip = "BLUE"; //--- ToDo: Localize;
      };
      class IconAlphaColor: Playermarker_RscSlider_Color
      {
      	idc = 1908;
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.676 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.022 * safezoneH;
        colorActive[] = {1, 1, 1, 1};
        color[] = {1, 1, 1, 1};
        onSliderPosChanged = "playermarker_iconColor set [3,(_this select 1)/10]; ";
        onLoad = "(_this select 0) sliderSetPosition ((playermarker_iconColor select 3) * 10)";
      	tooltip = "ALPHA"; //--- ToDo: Localize;
      };
      class IconExampleColor: Playermarker_RscStructuredText
      {
      	idc = 1108;
        text = "";
      	x = 0.5825 * safezoneW + safezoneX;
      	y = 0.709 * safezoneH + safezoneY;
      	w = 0.108281 * safezoneW;
      	h = 0.033 * safezoneH;
        onLoad = "(_this select 0) ctrlSetBackgroundColor playermarker_iconColor";
      	colorBackground[] = {-1,-1,-1,1};
      };

      class RscSlider_1900: Playermarker_RscSlider_Color
      {
      	idc = 1900;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.346 * safezoneH + safezoneY;
      	w = 0.180469 * safezoneW;
      	h = 0.033 * safezoneH;
        color[] = {1, 1, 1, 1};
        colorActive[] = {1, 1, 1, 1};
        onSliderPosChanged = "playermarker_nameDistance = sliderPosition (_this select 0); (_this select 0) ctrlSetTooltip format['%1m',floor(sliderPosition (_this select 0))];";
        onLoad = "(_this select 0) sliderSetRange [0, viewDistance]; (_this select 0) sliderSetPosition playermarker_nameDistance; (_this select 0) ctrlSetTooltip format['%1m',playermarker_nameDistance];";
      };
      class RscStructuredText_1103: Playermarker_RscText
      {
      	idc = 1103;
      	text = "Maximum Name Distance"; //--- ToDo: Localize;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.313 * safezoneH + safezoneY;
      	w = 0.180469 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
      	tooltip = "Change the color of names"; //--- ToDo: Localize;
      };
      class RscStructuredText_1104: Playermarker_RscText
      {
      	idc = 1104;
      	text = "Maximum Icon Distance"; //--- ToDo: Localize;
      	x = 0.5 * safezoneW + safezoneX;
      	y = 0.313 * safezoneH + safezoneY;
      	w = 0.185625 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
      	tooltip = "Change the color of names"; //--- ToDo: Localize;
      };
      class RscSlider_1909: Playermarker_RscSlider_Color
      {
      	idc = 1909;
      	x = 0.5 * safezoneW + safezoneX;
      	y = 0.346 * safezoneH + safezoneY;
      	w = 0.185625 * safezoneW;
      	h = 0.033 * safezoneH;
        color[] = {1, 1, 1, 1};
        colorActive[] = {1, 1, 1, 1};
        onSliderPosChanged = "playermarker_iconDistance = sliderPosition (_this select 0); (_this select 0) ctrlSetTooltip format['%1m',floor(sliderPosition (_this select 0))];";
        onLoad = "(_this select 0) sliderSetRange [0, viewDistance]; (_this select 0) sliderSetPosition playermarker_iconDistance; (_this select 0) ctrlSetTooltip format['%1m',playermarker_iconDistance];";
      };
      class RscEdit_1400: Playermarker_RscEdit
      {
      	idc = 1400;
        text = "Icon";
      	x = 0.5 * safezoneW + safezoneX;
      	y = 0.434 * safezoneH + safezoneY;
      	w = 0.185625 * safezoneW;
      	h = 0.022 * safezoneH;
        onLoad = "(_this select 0) ctrlSetText playermarker_customIcon";
        onKeyDown = "playermarker_customIcon = ctrlText (_this select 0)";
      };
      class RscStructuredText_1109: Playermarker_RscStructuredText
      {
      	idc = -1;
      	text = "<t align='center' font='PuristaSemiBold'>Custom Icon Path</t>"; //--- ToDo: Localize;
        tooltip = "Choose a custom icon to show on group members. Click to reset icon"; //--- ToDo: Localize;
      	x = 0.5 * safezoneW + safezoneX;
      	y = 0.401 * safezoneH + safezoneY;
      	w = 0.185625 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
        onButtonClick = "playermarker_customIcon = '\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayerSetup\flag_opfor_ca.paa'; closeDialog 0; createDialog 'PlayerMarker_Settings'; ";
      };
      class RscStructuredText_1110: Playermarker_RscText
      {
      	idc = 1110;
      	text = "Custom Name"; //--- ToDo: Localize;
        tooltip = "Choose your custom name that will be shown to other players"; //--- ToDo: Localize;
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.401 * safezoneH + safezoneY;
      	w = 0.180469 * safezoneW;
      	h = 0.022 * safezoneH;
      	colorBackground[] = {-1,-1,-1,0};
      };
      class RscEdit_1401: Playermarker_RscEdit
      {
      	idc = 1401;
        text = "";
      	x = 0.314375 * safezoneW + safezoneX;
      	y = 0.434 * safezoneH + safezoneY;
      	w = 0.180469 * safezoneW;
      	h = 0.022 * safezoneH;
        onLoad = "(_this select 0) ctrlSetText (player getVariable ['playermarker_customName',profileName])";
        onKeyDown = "player setVariable ['playermarker_customName',ctrlText (_this select 0),true]";
      };
    };
};
