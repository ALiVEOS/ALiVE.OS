class RscText;
class RscHTML;

class newsfeed_dialog
{
	idd = 660002;
	movingEnable = 1;
	enableSimulation = 1;
	enableDisplay = 1;

	onLoad = "newsfeed_dialog = _this; disableSerialization;";


	class controls
	{

		class NewsTitle: RscText
				{
					colorBackground[] = {0.69,0.75,0.5,0.8};
					idc = 10032;
					x = "0 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
				};
				class NewsBackgroundDate: RscText
				{
					idc = 10022;
					x = "0 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "1.1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorBackground[] = {0,0,0,0.4};
				};
				class NewsBackground: RscText
				{
					idc = 10052;
					x = "0 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "2.2 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "15 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "17.5 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorBackground[] = {0,0,0,0.4};
				};
				class NewsText: RscHTML
				{
					shadow = 0;
					class H1
					{
						font = "PuristaMedium";
						fontBold = "PuristaLight";
						sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.2)";
					};
					class H2: H1
					{
						sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.2)";
						font = "PuristaLight";
					};
					class P: H1
					{
						sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
						fontBold = "PuristaLight";
					};
					colorBold[] = {0.6,0.6,0.6,1};
					colorLink[] = {0.69,0.75,0.5,1};
					colorLinkActive[] = {0.69,0.75,0.5,1};
					idc = 10042;
					x = "0.5 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "-0.1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "14 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "19.5 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
				};
	};
};
