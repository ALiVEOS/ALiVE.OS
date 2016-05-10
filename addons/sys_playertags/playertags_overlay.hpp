#define PLAYERTAGSOVERLAY_IDD 990
#define PLAYERTAGSOVERLAY_TEXT0_IDC 991

#define CT_STATIC 0
#define ST_CENTER 0x02
#define CT_STRUCTURED_TEXT 13
#define FontM "PuristaSemibold"

#define BORDER 0.05
#define WIDTH 0.4
#define HEIGHT 0.3


class playertagsRecogText {
	type = CT_STRUCTURED_TEXT;
	style = ST_CENTER;
	text = "";
	access = 0;
	font = FontM;
	sizeEx = 0.023;
	size = 0.06;

	colorBackground[] = { 1, 1, 1, 0.2 };
	colorText[] = { 0, 0, 0, 1 };

	x = BORDER;
	y = BORDER;
	w = WIDTH;
	h = HEIGHT;

	class Attributes {
		font = FontM;
		color = "#ffffff";
		align = "center";
		valign = "middle";
		shadow = 1;
		shadowColor = "#000000";
		size = "1";
	};
};

	class playertagsOverlayRsc {
		idd = PLAYERTAGSOVERLAY_IDD;
		movingEnable = 1;
		fadein = 0.0;
		fadeout = 0.0;
		duration = 1e6;
		access = 0;
		onLoad = "_this call ALIVE_fnc_playertagsRecogniseOverlayCtrl;";

		class objects {};
		class controlsBackground {};
		class controls {
			class playertag0 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC;
			};
			class playertag1 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 1;
			};
			class playertag2 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 2;
			};
			class playertag3 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 3;
			};
			class playertag4 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 4;
			};
			class playertag5 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 5;
			};
			class playertag6 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 6;
			};
			class playertag7 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 7;
			};
			class playertag8 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 8;
			};
			class playertag9 : playertagsRecogText {
				idc = PLAYERTAGSOVERLAY_TEXT0_IDC + 9;
			};
		};
	};