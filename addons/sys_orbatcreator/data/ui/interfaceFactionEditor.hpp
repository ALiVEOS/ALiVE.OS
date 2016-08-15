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

    class controls {

        // common controls

        class buttonOk : orbatCreator_common_popup_ok {
            idc = 8305;
        };

        class buttonCancel : orbatCreator_common_popup_cancel {
            idc = 8306;
        };

        // standard controls

        class controlsGroup_attributes : orbatCreator_common_popup_controlsGroup {
            idc = 8307;

            class controls {

                class properties_title: orbatCreator_RscText {
                    idc = 8308;
                    text = "General";
                    x = 0.37 * safezoneW + safezoneX;
                    y = 0 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                    sizeEx = BASE_SIZE_TEXT * 1.7;
                };

                class displayName_title: orbatCreator_RscText {
                    idc = 8309;
                    text = "Display Name";
                    x = 0.225 * safezoneW + safezoneX;
                    y = 0.07 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_input: orbatCreator_RscEdit {
                    idc = 8310;
                    x = 0.40 * safezoneW + safezoneX;
                    y = 0.075 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_title: orbatCreator_RscText {
                    idc = 8311;
                    text = "Class Name";
                    x = 0.225 * safezoneW + safezoneX;
                    y = 0.125 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class className_input: orbatCreator_RscEdit {
                    idc = 8312;
                    x = 0.40 * safezoneW + safezoneX;
                    y = 0.13 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class side_title: orbatCreator_RscText {
                    idc = 8313;
                    text = "Side";
                    x = 0.225 * safezoneW + safezoneX;
                    y = 0.1975 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_input: orbatCreator_RscCombo {
                    idc = 8314;
                    x = 0.40 * safezoneW + safezoneX;
                    y = 0.198 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class appearance: orbatCreator_RscText {
                    idc = 8315;
                    text = "Appearance";
                    x = 0.355 * safezoneW + safezoneX;
                    y = 0.280 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                    sizeEx = BASE_SIZE_TEXT * 1.7;
                };

                class flag_title : orbatCreator_RscText {
                    idc = 8316;
                    text = "Flag";
                    x = 0.225 * safezoneW + safezoneX;
                    y = 0.350 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class flag_input: orbatCreator_RscCombo {
                    idc = 8317;
                    x = 0.40 * safezoneW + safezoneX;
                    y = 0.355 * safezoneH;
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