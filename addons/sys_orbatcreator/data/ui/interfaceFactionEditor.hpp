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
                    x = 0 * safezoneW;
                    y = 0.01 * safezoneH;
                    w = 0.44 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class general_title : orbatCreator_common_popup_attribute_title {
                    idc = 8310;
                    text = "General";
                    x = 0.005 * safezoneW;
                    y = 0.02 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8311;
                    text = "Display Name";
                    x = 0.033 * safezoneW;
                    y = 0.09 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_input : orbatCreator_RscEdit {
                    idc = 8312;
                    x = 0.172 * safezoneW;
                    y = 0.095 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8315;
                    text = "Side";
                    x = 0.033 * safezoneW;
                    y = 0.145 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_input : orbatCreator_RscCombo {
                    idc = 8316;
                    x = 0.172 * safezoneW;
                    y = 0.15 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class country_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8321;
                    text = "Country";
                    x = 0.033 * safezoneW;
                    y = 0.2 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                    tooltip = "Use an ISO Alpha 2 Country code i.e. US, GB etc.";
                };

                class country_input : orbatCreator_RscEdit {
                    idc = 8322;
                    x = 0.172 * safezoneW;
                    y = 0.205 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class force_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8323;
                    text = "Armed Force";
                    x = 0.033 * safezoneW;
                    y = 0.255 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                    tooltip = "Use Army, Navy, Marines, AF (for Air Force).";
                };

                class force_input : orbatCreator_RscEdit {
                    idc = 8324;
                    x = 0.172 * safezoneW;
                    y = 0.26 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class camo_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8326;
                    text = "Theater/Camo";
                    x = 0.033 * safezoneW;
                    y = 0.31 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                    tooltip = "Use DES, WDL or SNW. Leave blank if the faction use a multi-terrain camo.";
                };

                class camo_input : orbatCreator_RscEdit {
                    idc = 8327;
                    x = 0.172 * safezoneW;
                    y = 0.315 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_button_generateClassname : orbatCreator_RscButton {
                    idc = 8325;
                    text = "Generate Classname";
                    tooltip = "Generate a classname based on the side, country and armed force.";
                    x = 0.005 * safezoneW;
                    y = 0.365 * safezoneH;
                    w = 0.10 * safezoneW;
                    h = 0.035 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class classname_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8313;
                    text = "Class Name";
                    x = 0.033 * safezoneW;
                    y = 0.365 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class classname_input : orbatCreator_RscEdit {
                    idc = 8314;
                    x = 0.172 * safezoneW;
                    y = 0.37 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class appearance_divider : orbatCreator_RscText {
                    idc = 8317;
                    text = "";
                    x = 0 * safezoneW;
                    y = 0.42 * safezoneH;
                    w = 0.44 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class appearance_title : orbatCreator_common_popup_attribute_title {
                    idc = 8318;
                    text = "Appearance";
                    x = 0.005 * safezoneW;
                    y = 0.43 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class flag_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 8319;
                    text = "Flag";
                    x = 0.033 * safezoneW;
                    y = 0.485 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class flag_input : orbatCreator_RscCombo {
                    idc = 8320;
                    x = 0.172 * safezoneW;
                    y = 0.490 * safezoneH;
                    w = 0.225 * safezoneW;
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
            text = "Edit Faction";
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