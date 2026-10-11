#include "recruit_common.hpp"

// The recruitment window (#1075): opened by "Recruitment" on an object synced to a
// Recruitment module. A list of the soldiers and vehicles on offer, what the selected one
// is, how full the player's group and vehicle allowance are, and Recruit.
// ALiVE_fnc_recruitWindow fills and drives it.

class ALiVE_RecruitWindow {
    idd = 9270;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_recruitWindow";

    class controls {
        class RecruitUI_Background: RecruitUI_RscText {
            idc = 92700;
            x = 0.30 * safezoneW + safezoneX;
            y = 0.26 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.44 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class RecruitUI_Header: RecruitUI_RscText {
            idc = 92701;
            text = "Recruitment";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.232 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class RecruitUI_List: RecruitUI_RscListBox {
            idc = 92702;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.275 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.41 * safezoneH;
            colorBackground[] = {0,0,0,0.3};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
            onLBSelChanged = "['select'] call ALiVE_fnc_recruitWindow";
            onLBDblClick = "['recruit'] call ALiVE_fnc_recruitWindow";
        };
        class RecruitUI_Details: RecruitUI_RscStructuredText {
            idc = 92703;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.275 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.30 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RecruitUI_Status: RecruitUI_RscStructuredText {
            idc = 92704;
            x = 0.51 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RecruitUI_Recruit: RecruitUI_RscButton {
            idc = 92705;
            text = "Recruit";
            action = "['recruit'] call ALiVE_fnc_recruitWindow";
            x = 0.51 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class RecruitUI_Close: RecruitUI_RscButton {
            idc = 92706;
            text = "Close";
            action = "closeDialog 0";
            x = 0.605 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.085 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
