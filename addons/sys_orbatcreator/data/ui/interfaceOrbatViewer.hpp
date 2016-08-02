class ALiVE_orbatCreator_interface_orbatViewer {
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

            text = "Order of Battle Viewer";
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

        class orbatViewer_title_faction: orbatCreator_RscText {
            idc = 8004;
            text = "Faction:";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3.1 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,0};
            sizeEx = 1.5 * GUI_GRID_H;
        };
    };

    class controls {

        class orbatViewer_combo_faction: orbatCreator_RscCombo {
            idc = 8008;
            x = -7.5 * GUI_GRID_W + GUI_GRID_X;
            y = -2.6 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.04;
        };

        class orbatViewer_button_big_1: orbatCreator_RscButtonBig {
            idc = 8005;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_2: orbatCreator_RscButtonBig {
            idc = 8006;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_big_3: orbatCreator_RscButtonBig {
            idc = 8007;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class orbatViewer_button_ORBAT: orbatCreator_RscTree {
            idc = 8009;

            x = -14 * GUI_GRID_W + GUI_GRID_X;
            y = 1 * GUI_GRID_H + GUI_GRID_Y;
            w = 68 * GUI_GRID_W;
            h = 29.34 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

    };
};