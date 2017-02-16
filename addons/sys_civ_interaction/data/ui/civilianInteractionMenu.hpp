// GUI editor: configfile >> "ALiVE_civ_interaction_menu"

class ALiVE_civ_interaction_menu {
	idd = 9200;
	movingEnable = 1;
	onLoad = "";
	onUnload = "['onUnload'] call ALiVE_fnc_civInteractionOnAction";

	class controlsBackground {

		class civ_interaction_inventory_Background: civ_interaction_RscText {
			idc = 9201;

            x = 0.690312 * safezoneW + safezoneX;
            y = 0.094 * safezoneH + safezoneY;
            w = 0.190312 * safezoneW;
            h = 0.7 * safezoneH;
			colorBackground[] = COLOR_BLACK(1);
		};

		class civ_interaction_inventory_Header: civ_interaction_RscText {
			idc = 9202;

			moving = 1;
			text = " Inventory";
            x = 0.68375 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = COLOR_ARMA_BG;
		};

		class civ_interaction_Background: civ_interaction_RscText {
			idc = 9203;

            x = 0.21125 * safezoneW + safezoneX;
            y = 0.094 * safezoneH + safezoneY;
            w = 0.4725 * safezoneW;
            h = 0.7 * safezoneH;
			colorBackground[] = COLOR_BLACK(1);
		};

		class civ_interaction_Header: civ_interaction_RscText {
			idc = 9204;

			moving = 1;
			text = "Civilian Interaction";
            x = 0.21125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.4725 * safezoneW;
            h = 0.028 * safezoneH;
			colorBackground[] = COLOR_ARMA_BG;
		};

		class civ_interaction_QuestionsTitle: civ_interaction_RscText {
			idc = 9205;

			text = "Questions";
            x = 0.244062 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.028 * safezoneH;
		};

		class civ_interaction_ResponseTitle: civ_interaction_RscText {
			idc = 9206;

			text = "Response";
            x = 0.244062 * safezoneW + safezoneX;
            y = 0.5 * safezoneH + safezoneY;
            w = 0.0590625 * safezoneW;
            h = 0.042 * safezoneH;
		};

		class civ_interaction_CivName: civ_interaction_RscText {
			idc = 9207;

			text = "Name";
            x = 0.401563 * safezoneW + safezoneX;
            y = 0.1024 * safezoneH + safezoneY;
            w = 0.21 * safezoneW;
            h = 0.056 * safezoneH;
		};

		class civ_interaction_ResponseBox: civ_interaction_RscStructuredText {
			idc = 9211;

            x = 0.223063 * safezoneW + safezoneX;
            y = 0.542 * safezoneH + safezoneY;
            w = 0.439687 * safezoneW;
            h = 0.224 * safezoneH;
			colorBackground[] = COLOR_BLACK(0);
		};

		class civ_interaction_ProgressBarTitle: civ_interaction_RscText {
			idc = 9212;

			text = "";
            x = 0.414687 * safezoneW + safezoneX;
            y = 0.71 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.028 * safezoneH;
		};

	};

	class controls {

		class civ_interaction_QuestionListOne: civ_interaction_RscListBox {
			idc = 9208;

			text = "";
			font = "PuristaMedium";
            x = 0.224375 * safezoneW + safezoneX;
            y = 0.192 * safezoneH + safezoneY;
            w = 0.223125 * safezoneW;
            h = 0.2604 * safezoneH;
			colorBackground[] = {0.173,0.173,0.173,0.8};
		};

		class civ_interaction_QuestionListTwo: civ_interaction_RscListBox {
			idc = 9209;

			text = "";
			font = "PuristaMedium";
            x = 0.454062 * safezoneW + safezoneX;
            y = 0.192 * safezoneH + safezoneY;
            w = 0.216562 * safezoneW;
            h = 0.2604 * safezoneH;
			colorBackground[] = {0.173,0.173,0.173,0.8};
		};

		class civ_interaction_AskQuestion: civ_interaction_RscButton {
			idc = 9210;

			text = "Ask Question";
            x = 0.224375 * safezoneW + safezoneX;
            y = 0.4636 * safezoneH + safezoneY;
            w = 0.44625 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BURNT_ORANGE_MODERATE;
		};

		class civ_interaction_Detain: civ_interaction_RscButton {
			idc = 9214;

			text = "Detain";
            x = 0.335938 * safezoneW + safezoneX;
            y = 0.801 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_GetDown: civ_interaction_RscButton {
			idc = 9215;

			text = "Get Down";
            x = 0.414687 * safezoneW + safezoneX;
            y = 0.801 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_GoAway: civ_interaction_RscButton {
			idc = 9216;

			text = "Go Away";
            x = 0.493437 * safezoneW + safezoneX;
            y = 0.801 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_Close: civ_interaction_RscButton {
			idc = 9217;

			text = "Close";
            x = 0.21125 * safezoneW + safezoneX;
            y = 0.801 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_Search: civ_interaction_RscButton {
			idc = 9218;

			text = "Search";
			tooltip = "Search the civilian's inventory";
            x = 0.611562 * safezoneW + safezoneX;
            y = 0.801 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_inventory_GearList: civ_interaction_RscListNBox {
			idc = 9219;

            x = 0.696219 * safezoneW + safezoneX;
            y = 0.108 * safezoneH + safezoneY;
            w = 0.177187 * safezoneW;
            h = 0.672 * safezoneH;
			colorBackground[] = COLOR_BLACK(0);
			rowHeight = 0.08;
		};

		class civ_interaction_inventory_ButtonTwo: civ_interaction_RscButton {
			idc = 9220;

			text = "";
            x = 0.690312 * safezoneW + safezoneX;
            y = 0.8444 * safezoneH + safezoneY;
            w = 0.190312 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

		class civ_interaction_inventory_ButtonThree: civ_interaction_RscButton {
			idc = 9221;

			text = "";
            x = 0.690312 * safezoneW + safezoneX;
            y = 0.8878 * safezoneH + safezoneY;
            w = 0.190312 * safezoneW;
            h = 0.0336 * safezoneH;
			colorBackground[] = COLOR_BLACK_SOFT;
		};

	};
};