#include "soldier_common.hpp"

// The soldier interaction window: a surrendered enemy soldier or a friendly AI soldier, opened by
// "Talk to soldier" (scroll wheel, or the ACE interaction menu). Laid out like Civilian
// Interaction; ALiVE_fnc_C2ISTARSoldierInteract fills it, shows the buttons that fit the soldier
// and handles them. One row of buttons serves both kinds: the prisoner set and the friendly set
// share the slots and only one set is shown.

class ALiVE_SoldierInteraction {
    idd = 9260;
    movingEnable = 1;
    onUnload = "['closed'] call ALiVE_fnc_C2ISTARSoldierInteract";

    class controls {
        class SoldierInteract_Background: SoldierInteract_RscText {
            idc = 92600;
            x = 0.30 * safezoneW + safezoneX;
            y = 0.30 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.31 * safezoneH;
            colorBackground[] = {0,0,0,0.65};
        };
        class SoldierInteract_Header: SoldierInteract_RscText {
            idc = 92603;
            text = "$STR_ALIVE_C2ISTAR_SI_WINDOW";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.272 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.788,0.443,0.157,0.65};
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
        };
        class SoldierInteract_Name: SoldierInteract_RscText {
            idc = 92601;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.05 * safezoneH;
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.6)";
        };
        class SoldierInteract_Response: SoldierInteract_RscStructuredText {
            idc = 92602;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.37 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.145 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class SoldierInteract_Question: SoldierInteract_RscButton {
            idc = 92610;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_QUESTION";
            action = "['button', 'question'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.3000 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Restrain: SoldierInteract_RscButton {
            idc = 92611;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_RESTRAIN";
            action = "['button', 'restrain'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.3667 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Follow: SoldierInteract_RscButton {
            idc = 92612;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_FOLLOW";
            action = "['button', 'follow'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.4334 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Stay: SoldierInteract_RscButton {
            idc = 92613;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_STAY";
            action = "['button', 'stay'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.5001 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Search: SoldierInteract_RscButton {
            idc = 92614;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_SEARCH";
            action = "['button', 'search'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.5668 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Release: SoldierInteract_RscButton {
            idc = 92615;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_RELEASE";
            action = "['button', 'release'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.6335 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Friendly: SoldierInteract_RscButton {
            idc = 92620;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_FRIENDLIES";
            action = "['button', 'friendlies'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.3000 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Seen: SoldierInteract_RscButton {
            idc = 92621;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_SEEN";
            action = "['button', 'seen'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.3667 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class SoldierInteract_Headed: SoldierInteract_RscButton {
            idc = 92622;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_HEADED";
            action = "['button', 'headed'] call ALiVE_fnc_C2ISTARSoldierInteract";
            x = 0.4334 * safezoneW + safezoneX;
            y = 0.525 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class SoldierInteract_Close: SoldierInteract_RscButton {
            idc = 92609;
            text = "$STR_ALIVE_C2ISTAR_SI_BTN_CLOSE";
            action = "closeDialog 0";
            x = 0.6333 * safezoneW + safezoneX;
            y = 0.567 * safezoneH + safezoneY;
            w = 0.0647 * safezoneW;
            h = 0.035 * safezoneH;
        };
    };
};
