class HudNamesLeft {
	idd = -1;
    fadeout=0;
    fadein=0;
	duration = 10000000000;
	name= "HudNamesLeft";
	onLoad = "uiNamespace setVariable ['HudNamesLeft', _this select 0]";
	
	class controlsBackground {
		class HudNames_l:CIRscStructuredText
		{
			idc = 99999;
			type = CT_STRUCTURED_TEXT;
			size = 0.040;
			x = safezoneX + 0.1;
			y = safezoneY + safezoneh/4;
			w = 0.3; 
			h = 0.5;
			colorText[] = {1,1,1,1};
			lineSpacing = 3;
			colorBackground[] = {0,0,0,0};
			text = "";
			font = "PuristaSemibold";
			shadow = 2;
			class Attributes {
				align = "left";
			};
		};

	};
};