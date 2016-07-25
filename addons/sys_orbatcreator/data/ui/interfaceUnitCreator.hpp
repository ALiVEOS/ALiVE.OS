class ALiVE_orbatCreator_interface_unitEditor {
    idd = 9000;

    class controlsBackground {

        class unitCreator_header: orbatCreator_RscText {
            idc = 9001;

            text = "";
            x = -14.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 69 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class unitCreator_header_title: orbatCreator_RscText {
            idc = 9002;

            text = "Unit Creator";
            x = -13.75 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

        class unitCreator_headerLogo: orbatCreator_RscPicture {
            idc = 9003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.475 * GUI_GRID_H + GUI_GRID_Y;
            w = 24 * GUI_GRID_W;
            h = 1.98 * GUI_GRID_H;
        };

        class unitCreator_header_unitClasses: orbatCreator_RscText {
            idc = 9004;
            text = "Unit Classes";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 0.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };

    class controls {

        class unitCreator_button_big_one: orbatCreator_RscButton {
            idc = 9005;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_button_big_two: orbatCreator_RscButton {
            idc = 9006;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_button_big_three: orbatCreator_RscButton {
            idc = 9007;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_list_unitClasses: orbatCreator_RscTree {
            idc = 9008;
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 18 * GUI_GRID_H;
            colorBorder[] = {0,0,0,1};
        };

        class unitCreator_button_unitClasses_one: orbatCreator_RscButton {
            idc = 9009;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 21 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_button_unitClasses_two: orbatCreator_RscButton {
            idc = 9010;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 23 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_button_unitClasses_three: orbatCreator_RscButton {
            idc = 9011;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 25 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitCreator_button_unitClasses_four: orbatCreator_RscButton {
            idc = 9012;

            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 27 * GUI_GRID_H + GUI_GRID_Y;
            w = 14 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

    };
};