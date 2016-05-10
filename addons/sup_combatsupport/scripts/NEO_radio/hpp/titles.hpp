class NEO_radioHintInterface
{ 
	idd=-1;
	movingEnable=1;
	duration=10e10;
	fadein=0;
	fadeout=1;
	name="NEO_radioHintInterface"; 
	onload = "uinamespace setvariable [""NEO_radioHint"", (_this select 0)]";
	
	class controlsbackground{};
	class controls
	{
		class NEO_radioHint
		{
			idc = 655000;
			text="scripts\NEO_radio\img\hint.paa";
			x = "safeZoneX + (safeZoneW / 1.3)";
			y = "safeZoneY + (safeZoneH / 1.2)";
			w = "(safeZoneW / 5)";
			h = "(safeZoneH / 10)";
			colortext[] = {1,1,1,0.7};
			access=0;
			type=0;
			style=48;
			colorBackground[]={0,0,0,0};
			font="TahomaB";
			sizeEx=0;
			lineSpacing=0;
		};
		
		class NEO_radioHintText : NEO_RscText
		{
			idc = 655001;
			x = "safeZoneX + (safeZoneW / 1.3)";
			y = "safeZoneY + (safeZoneH / 1.2)";
			w = "(safeZoneW / 5)";
			h = "(safeZoneH / 10)";
			text = "";
			colorBackground[]={0,0,0,0};
			class Attributes 
			{ 
				font = "PuristaLight"; 
				color = "#FFFFFF"; 
				align = "center"; 
				valign = "middle"; 
				shadow = true;
				shadowColor = "#000000";
				size = "1.1";
			};
		};
	};
};
