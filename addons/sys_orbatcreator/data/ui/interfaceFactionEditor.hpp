class ALiVE_orbatCreator_interface_factionEditor {
    idd = 8000;

    class controlsBackground {

        class orbatViewer_background: orbatCreator_RscPicture {
            idc = 8001;
            text = "x\alive\addons\ui\alive_bg.paa";
            x = -0.003125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 1.00625 * safezoneW;
            h = 1.008 * safezoneH;
            colorBackground[] = {0.714,0.843,0.659,1};
        };

        class orbatViewer_header: orbatCreator_RscText {
            idc = 8002;

            text = "";
            x = -0.003125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 1.00625 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class orbatViewer_header_title: orbatCreator_RscText {
            idc = 8002;

            text = "Faction Editor";
            x = 0.0078125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class orbatViewer_headerLogo: orbatCreator_RscPicture {
            idc = 8003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 0.653125 * safezoneW + safezoneX;
            y = -0.00315998 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.05544 * safezoneH;
        };

        class orbatViewer_factions_header: orbatCreator_RscText {
            idc = 8005;
            style = 0 + 0x02;
            text = "Factions";
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_divider: orbatCreator_RscText {
            idc = 8006;
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.6974 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.0014 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

        class orbatViewer_factions_title_side: orbatCreator_RscText {
            idc = 8007;
            text = "Side";
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.71 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class orbatViewer_factions_title_name: orbatCreator_RscText {
            idc = 8008;
            text = "Name";
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.766 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class orbatViewer_factions_title_classname: orbatCreator_RscText {
            idc = 8009;
            text = "Classname";
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.822 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
            sizeEx = 0.035;
        };

        class orbatViewer_factions_title_flag: orbatCreator_RscText {
            idc = 8010;
            text = "Flag";
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.878 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

    };

    class controls {

        class orbatViewer_button_big_1: orbatCreator_RscButtonBig {
            idc = 8011;

            text = "";
            x = 0.478125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_2: orbatCreator_RscButtonBig {
            idc = 8012;

            text = "";
            x = 0.653125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_3: orbatCreator_RscButtonBig {
            idc = 8013;

            text = "";
            x = 0.828125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_factions_list_factions: orbatCreator_RscListbox {
            idc = 8014;
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.178 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.364 * safezoneH;
        };

        class orbatViewer_groups_tree: orbatCreator_RscTree {
            idc = 8015;

            x = 0.339583 * safezoneW + safezoneX;
            y = 0.178 * safezoneH + safezoneY;
            w = 0.65625 * safezoneW;
            h = 0.82152 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class orbatViewer_factions_button_1: orbatCreator_RscButtonBig {
            idc = 8016;
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.556 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_button_2: orbatCreator_RscButtonBig {
            idc = 8017;
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.598 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_button_3: orbatCreator_RscButtonBig {
            idc = 8018;
            x = 0.00416668 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_side: orbatCreator_RscCombo {
            idc = 8019;
            x = 0.0770833 * safezoneW + safezoneX;
            y = 0.7142 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class orbatViewer_factions_input_name: orbatCreator_RscEdit {
            idc = 8020;
            x = 0.0770833 * safezoneW + safezoneX;
            y = 0.7702 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_classname: orbatCreator_RscEdit {
            idc = 8021;
            x = 0.0770833 * safezoneW + safezoneX;
            y = 0.8262 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_flag: orbatCreator_RscCombo {
            idc = 8022;
            x = 0.0770833 * safezoneW + safezoneX;
            y = 0.8822 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
        };



    };
};