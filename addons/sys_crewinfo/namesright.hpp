class HudNamesRight {
	idd = -1;
    fadeout=0;
    fadein=0;
	duration = 10000000000;
	name= "HudNamesRight";
	onLoad = "uiNamespace setVariable ['HudNamesRight', _this select 0]";
	
	class controlsBackground {
		class HudNames_r:CIRscStructuredText
		{
			idc = 99999;
			type = CT_STRUCTURED_TEXT;
			size = 0.040;
			x = safezoneX + safezoneW - 0.3;
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