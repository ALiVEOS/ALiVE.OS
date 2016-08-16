class ALiVE_orbatCreator_interface_factionEditor {
    idd = 8000;

    class controlsBackground {

        // common header controls

        class background_grid : orbatCreator_common_backgroundGrid {
            idc = 8010;
        };
        class header_background : orbatCreator_common_header_green {
            idc = 8011;
        };
        class header_interfaceTitle : orbatCreator_common_header_interfaceTitle {
            idc = 8012;
        };
        class header_banner : orbatCreator_common_header_banner {
            idc = 8013;
        };

        // standard controls

        class factions_header : orbatCreator_RscText {
            idc = 8001;
            style = 0 + 0x02;
            text = "Factions";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.178 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class groups_header : orbatCreator_RscText {
            idc = 8002;

            x = 0.308 * safezoneW + safezoneX;
            y = 0.178 * safezoneH + safezoneY;
            w = 0.695 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class factions_flag : orbatCreator_RscPicture {
            idc = 8003;
            text = "#(argb,8,8,3)color(1,1,1,1)";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.78 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.21 * safezoneH;
        };

    };

    class controls {

        // common header controls

        class header_menuStrip : orbatCreator_common_header_menuStrip {};

        // standard controls

        class factions_list_factions : orbatCreator_RscListbox {
            idc = 8004;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.364 * safezoneH;
        };

        class groups_tree : orbatCreator_RscTree {
            idc = 8005;

            x = 0.295833 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.704375 * safezoneW;
            h = 0.79352 * safezoneH;
            colorBackground[] = COLOR_BLACK(0);
        };

        class factions_button_1 : orbatCreator_RscButtonBig {
            idc = 8006;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.598 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class factions_button_2 : orbatCreator_RscButtonBig {
            idc = 8007;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class factions_button_3 : orbatCreator_RscButtonBig {
            idc = 8008;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.682 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class factions_button_4 : orbatCreator_RscButtonBig {
            idc = 8009;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.724 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
        };

    };
};



class ALiVE_orbatCreator_interface_createFaction {
    idd = 8300;

    class controlsBackground {

        // common controls

        class background_grid : orbatCreator_common_backgroundGrid {
            idc = 8301;
        };

        class header : orbatCreator_common_popup_header {
            idc = 8302;
            text = "Create Faction";
        };

        class background : orbatCreator_common_popup_background {
            idc = 8303;
        };

        class footer : orbatCreator_common_popup_footer {
            idc = 8304;
        };

        class context : orbatCreator_common_popup_context {
            idc = 8305;
        };

        // standard controls

    };

    class controls {

        // common controls

        class buttonOk : orbatCreator_common_popup_ok {
            idc = 8306;
        };

        class buttonCancel : orbatCreator_common_popup_cancel {
            idc = 8307;
        };

        // standard controls

        class controlsGroup_attributes : orbatCreator_common_popup_controlsGroup {
            idc = 8308;

            class controls {

                class general_divider : orbatCreator_RscText {
                    idc = 8309;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.01 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class general_title : orbatCreator_common_popup_attribute_title {
                    idc = 8310;
                    text = "General";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.02 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8311;
                    text = "Display Name";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.09 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_input : orbatCreator_RscEdit {
                    idc = 8312;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.095 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8313;
                    text = "Class Name";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.145 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class className_input : orbatCreator_RscEdit {
                    idc = 8314;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.15 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8315;
                    text = "Side";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.2175 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_input : orbatCreator_RscCombo {
                    idc = 8316;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.218 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class appearance_divider : orbatCreator_RscText {
                    idc = 8317;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.29 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class appearance_title : orbatCreator_common_popup_attribute_title {
                    idc = 8318;
                    text = "Appearance";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.30 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class flag_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8319;
                    text = "Flag";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.370 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class flag_input : orbatCreator_RscCombo {
                    idc = 8320;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.375 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

            };
        };

    };
};



class ALiVE_orbatCreator_interface_editFaction : ALiVE_orbatCreator_interface_createFaction {

    class controlsBackground {

        // common controls

        class background_grid : orbatCreator_common_backgroundGrid {
            idc = 8318;
        };

        class header : orbatCreator_common_popup_header {
            idc = 8301;
            text = "Create Faction";
        };

        class background : orbatCreator_common_popup_background {
            idc = 8302;
        };

        class footer : orbatCreator_common_popup_footer {
            idc = 8304;
        };

        class context : orbatCreator_common_popup_context {
            idc = 8303;
        };

        // standard controls

    };

};