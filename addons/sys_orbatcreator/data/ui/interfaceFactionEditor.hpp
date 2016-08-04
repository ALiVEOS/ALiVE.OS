class ALiVE_orbatCreator_interface_factionEditor {
    idd = 8000;

    class controlsBackground {

        class orbatViewer_background: orbatCreator_RscPicture {
            idc = 8001;
            text = "x\alive\addons\ui\alive_bg.paa";
            x = -14.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 69 * GUI_GRID_W;
            h = 36 * GUI_GRID_H;
            colorBackground[] = {0.714,0.843,0.659,1};
        };

        class orbatViewer_header: orbatCreator_RscText {
            idc = 8002;

            text = "";
            x = -14.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 69 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class orbatViewer_header_title: orbatCreator_RscText {
            idc = 8002;

            text = "Faction Editor";
            x = -13.75 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

        class orbatViewer_headerLogo: orbatCreator_RscPicture {
            idc = 8003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.475 * GUI_GRID_H + GUI_GRID_Y;
            w = 24 * GUI_GRID_W;
            h = 1.98 * GUI_GRID_H;
        };

        class orbatViewer_factions_header: orbatCreator_RscText {
            idc = 8005;
            style = 0 + 0x02;
            text = "Factions";
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 0 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_divider: orbatCreator_RscText {
            idc = 8006;
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 19.55 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 0.05 * GUI_GRID_H;
            colorBackground[] = {1,1,1,1};
        };

        class orbatViewer_factions_title_side: orbatCreator_RscText {
            idc = 8007;
            text = "Side";
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 20 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class orbatViewer_factions_title_name: orbatCreator_RscText {
            idc = 8008;
            text = "Name";
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 22 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class orbatViewer_factions_title_classname: orbatCreator_RscText {
            idc = 8009;
            text = "Classname";
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 24 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 0.035;
        };

        class orbatViewer_factions_title_flag: orbatCreator_RscText {
            idc = 8010;
            text = "Flag";
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 26 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

    };

    class controls {

        class orbatViewer_button_big_1: orbatCreator_RscButtonBig {
            idc = 8011;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_2: orbatCreator_RscButtonBig {
            idc = 8012;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_3: orbatCreator_RscButtonBig {
            idc = 8013;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_factions_list_factions: orbatCreator_RscListbox {
            idc = 8014;
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 13 * GUI_GRID_H;
        };

        class orbatViewer_groups_tree: orbatCreator_RscTree {
            idc = 8015;

            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 45 * GUI_GRID_W;
            h = 29.34 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

        class orbatViewer_factions_button_1: orbatCreator_RscButtonBig {
            idc = 8016;
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 14.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_button_2: orbatCreator_RscButtonBig {
            idc = 8017;
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 16 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_button_3: orbatCreator_RscButtonBig {
            idc = 8018;
            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 17.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_side: orbatCreator_RscCombo {
            idc = 8019;
            x = -9 * GUI_GRID_W + GUI_GRID_X;
            y = 20.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class orbatViewer_factions_input_name: orbatCreator_RscEdit {
            idc = 8020;
            x = -9 * GUI_GRID_W + GUI_GRID_X;
            y = 22.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_classname: orbatCreator_RscEdit {
            idc = 8021;
            x = -9 * GUI_GRID_W + GUI_GRID_X;
            y = 24.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class orbatViewer_factions_input_flag: orbatCreator_RscCombo {
            idc = 8022;
            x = -9 * GUI_GRID_W + GUI_GRID_X;
            y = 26.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };



    };
};