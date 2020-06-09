#include "common.hpp"
class RscPicture;

class ALiVE_CivilianInteraction {
	idd = 923;
	movingEnable = 1;
	onUnload = "[ALiVE_civInteractHandler,'closeMenu'] call ALiVE_fnc_civInteract";

	class controls {

		class CivInteract_Background: CivInteract_RscText {
			idc = 9231;

            x = 0.2375 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.444792 * safezoneW;
            h = 0.588 * safezoneH;
			colorBackground[] = {0,0,0,0.65};
			colorActive[] = {0,0,0,0.65};
		};

		class CivInteract_Header: CivInteract_RscText {
			idc = 9232;

			text = "Civilian interaction";
            x = 0.2375 * safezoneW + safezoneX;
            y = 0.206 * safezoneH + safezoneY;
            w = 0.444792 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0.788,0.443,0.157,0.65};
			colorActive[] = {0.788,0.443,0.157,0.65};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
		};

		class CivInteract_QuestionsTitle: CivInteract_RscText {
			idc = 9233;

			text = "Questions";
            x = 0.434375 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
			colorActive[] = {0,0,0,0};
		};

		class CivInteract_QuestionList: CivInteract_RscListBox {
			idc = 9234;

            x = 0.244792 * safezoneW + safezoneX;
            y = 0.36 * safezoneH + safezoneY;
            w = 0.422917 * safezoneW;
            h = 0.196 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorActive[] = {0,0,0,0};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};

		class CivInteract_CivName: CivInteract_RscText {
			idc = 9236;

			x = 0.29375 * safezoneW + safezoneX;
			y = 0.258 * safezoneH + safezoneY;
			w = 0.233333 * safezoneW;
			h = 0.0559999 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 2)";
		};
		class CivInteract_Pic: RscPicture
		{
			idc = 1200;
			x = 0.247344 * safezoneW + safezoneX;
			y = 0.258 * safezoneH + safezoneY;
			w = 0.04125 * safezoneW;
			h = 0.055 * safezoneH;
		};
		class CivInteract_ResponseTitle: CivInteract_RscText {
			idc = 9238;

			text = "Response";
            x = 0.434375 * safezoneW + safezoneX;
            y = 0.5532 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
			colorActive[] = {0,0,0,0};
		};

		class CivInteract_ResponseList: CivInteract_RscStructuredText {
			idc = 9239;

            x = 0.252083 * safezoneW + safezoneX;
            y = 0.598 * safezoneH + safezoneY;
            w = 0.422917 * safezoneW;
            h = 0.21 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorActive[] = {0,0,0,0};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};

		class CivInteract_Detain: CivInteract_RscButton {
			idc = 92311;
			action = "[ALiVE_civInteractHandler,'Detain'] call ALiVE_fnc_civInteract";

			text = "Detain";
            x = 0.408854 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.028 * safezoneH;
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_GetDown: CivInteract_RscButton {
			idc = 92312;
			action = "[ALiVE_civInteractHandler,'getDown'] call ALiVE_fnc_civInteract";

			text = "Get Down";
            x = 0.478125 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_GoAway: CivInteract_RscButton {
			idc = 92313;
			action = "[ALiVE_civInteractHandler,'goAway'] call ALiVE_fnc_civInteract";

			text = "Go Away";
            x = 0.547396 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_Ration: CivInteract_RscButton
		{
			idc = 92314;
			action = "[ALiVE_civInteractHandler,'giveItem',['humratItem']] call ALiVE_fnc_civInteract";

			text = "Give Ration";
			x = 0.17 * safezoneW + safezoneX;
			y = 0.643 * safezoneH + safezoneY;
			w = 0.065625 * safezoneW;
			h = 0.0280001 * safezoneH;
			colorActive[] = {0,0,0,0.5};
		};
		
		class CivInteract_Water: CivInteract_RscButton
		{
			idc = 92315;
			action = "[ALiVE_civInteractHandler,'giveItem',['waterItem']] call ALiVE_fnc_civInteract";

			text = "Give Water";
			x = 0.17 * safezoneW + safezoneX;
			y = 0.687 * safezoneH + safezoneY;
			w = 0.065625 * safezoneW;
			h = 0.0280001 * safezoneH;
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_Close: CivInteract_RscButton {
			idc = 9237;
			action = "closeDialog 0";

			text = "Close";
            x = 0.2375 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_inventory_Background: CivInteract_RscText {
			idc = 9240;

            x = 0.689583 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.182292 * safezoneW;
            h = 0.588 * safezoneH;
			colorBackground[] = {0,0,0,0.65};
			colorActive[] = {0,0,0,0.65};
		};

		class CivInteract_inventory_Header: CivInteract_RscText {
			idc = 9241;

			text = "Inventory";
            x = 0.689583 * safezoneW + safezoneX;
            y = 0.206 * safezoneH + safezoneY;
            w = 0.182292 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0.788,0.443,0.157,0.65};
			colorActive[] = {0.788,0.443,0.157,0.65};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.1)";
		};

		class CivInteract_Search: CivInteract_RscButton {
			idc = 9242;
			action = "[nil,'toggleSearchMenu'] call ALiVE_fnc_civInteract";

			text = "Search";
            x = 0.616667 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.0663542 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_inventory_Close: CivInteract_RscButton {
			idc = 9243;
			action = "[nil,'toggleSearchMenu'] call ALiVE_fnc_civInteract";

			text = "Close";
            x = 0.689583 * safezoneW + safezoneX;
            y = 0.8276 * safezoneH + safezoneY;
            w = 0.182292 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
			class Attributes {
				font = "PuristaMedium";
				color = "#C0C0C0";
				align = "center";
				valign = "middle";
				shadow = true;
				shadowColor = "#000000";
			};
		};

		class CivInteract_inventory_GearList: CivInteract_RscListNBox {
			idc = 9244;
            x = 0.696875 * safezoneW + safezoneX;
            y = 0.248 * safezoneH + safezoneY;
            w = 0.167708 * safezoneW;
            h = 0.56 * safezoneH;
			colorBackground[] = {0.173,0.173,0.173,0.8};
			colorActive[] = {0.173,0.173,0.173,0.8};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			rowHeight = .05;
		};

		class CivInteract_inventory_Confiscate: CivInteract_RscButton {
			idc = 9245;
			action = "[nil,'confiscate'] call ALiVE_fnc_civInteract";

			text = "Confiscate";
            x = 0.689583 * safezoneW + safezoneX;
            y = 0.864 * safezoneH + safezoneY;
            w = 0.182292 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

		class CivInteract_inventory_OpenContainer: CivInteract_RscButton {
			idc = 9246;
			action = "[nil,'openGearContainer'] call ALiVE_fnc_civInteract";

            text = "View Contents";
            x = 0.689583 * safezoneW + safezoneX;
            y = 0.9004 * safezoneH + safezoneY;
            w = 0.182292 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
			colorActive[] = {0,0,0,0.5};
		};

	};

};