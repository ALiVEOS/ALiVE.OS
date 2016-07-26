class ALiVE_orbatCreator_interface_unitEditor {
    idd = 9000;

    class controlsBackground {

        class unitEditor_header: orbatCreator_RscText {
            idc = 9001;

            text = "";
            x = -14.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 69 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class unitEditor_header_title: orbatCreator_RscText {
            idc = 9002;

            text = "Unit Editor";
            x = -13.75 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

        class unitEditor_headerLogo: orbatCreator_RscPicture {
            idc = 9003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.475 * GUI_GRID_H + GUI_GRID_Y;
            w = 24 * GUI_GRID_W;
            h = 1.98 * GUI_GRID_H;
        };

        class unitEditor_title_faction: orbatCreator_RscText {
            idc = 9004;
            text = "Faction:";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3.1 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,0};
            sizeEx = 1.5 * GUI_GRID_H;
        };

        class unitEditor_header_unitClasses: orbatCreator_RscText {
            idc = 9005;
            text = "Unit Classes";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 0.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_header_unitClasses_frame: orbatCreator_RscFrame {
            idc = 9005;
            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 0.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

    };

    class controls {

        class unitEditor_combo_faction: orbatCreator_RscCombo {
            idc = 9006;
            x = -7.5 * GUI_GRID_W + GUI_GRID_X;
            y = -2.6 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.04;
        };

        class unitEditor_button_big_one: orbatCreator_RscButton {
            idc = 9007;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_big_two: orbatCreator_RscButton {
            idc = 9008;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_big_three: orbatCreator_RscButton {
            idc = 9009;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_list_unitClasses: orbatCreator_RscTree {
            idc = 9010;
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 18 * GUI_GRID_H;
            colorBorder[] = {0,0,0,1};
        };

        class unitEditor_button_unitClasses_one: orbatCreator_RscButton {
            idc = 9011;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 21 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_two: orbatCreator_RscButton {
            idc = 9012;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 23 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_three: orbatCreator_RscButton {
            idc = 9013;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 25 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_four: orbatCreator_RscButton {
            idc = 9014;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 27 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

    };
};