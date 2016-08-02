class ALiVE_orbatCreator_interface_groupEditor {
    idd = 11000;

    class controlsBackground {

        class groupEditor_header : orbatCreator_RscText {
            idc = 11001;

            text = "";
            x = -14.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 69 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class groupEditor_header_title : orbatCreator_RscText {
            idc = 11002;

            text = "Group Editor";
            x = -13.75 * GUI_GRID_W + GUI_GRID_X;
            y = -5.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {0,0,0,0};
        };

        class groupEditor_headerLogo : orbatCreator_RscPicture {
            idc = 11003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -5.475 * GUI_GRID_H + GUI_GRID_Y;
            w = 24 * GUI_GRID_W;
            h = 1.98 * GUI_GRID_H;
        };

        class groupEditor_title_faction : orbatCreator_RscText {
            idc = 11004;
            text = "Faction:";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3.1 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,0};
            sizeEx = 1.5 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_header: orbatCreator_RscText {
            idc = 11005;
            style = 0 + 0x02;
            text = "Available Assets";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 1.25 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

        class groupEditor_availableGroups_header: orbatCreator_RscText {
            idc = 11006;
            style = 0 + 0x02;
            text = "Groups";
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 1.25 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

        class groupEditor_selectedGroup_header: orbatCreator_RscText {
            idc = 11007;
            text = "Selected Group";
            x = 2.5 * GUI_GRID_W + GUI_GRID_X;
            y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 35 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

    };

    class controls {

        class groupEditor_combo_faction : orbatCreator_RscCombo {
            idc = 11008;
            x = -7.5 * GUI_GRID_W + GUI_GRID_X;
            y = -2.6 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.04;
        };

        class groupEditor_button_big_one : orbatCreator_RscButtonBig {
            idc = 11009;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class groupEditor_button_big_two : orbatCreator_RscButtonBig {
            idc = 11010;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class groupEditor_button_big_three : orbatCreator_RscButtonBig {
            idc = 11011;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_input_category: orbatCreator_RscCombo {
            idc = 11012;
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 2.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_list_units: orbatCreator_RscListbox {
            idc = 11013;
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 12 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_button_1: orbatCreator_RscButton {
            idc = 11014;
            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 17 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_button_2: orbatCreator_RscButton {
            idc = 11015;
            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 18.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_availableAssets_button_3: orbatCreator_RscButton {
            idc = 11016;
            text = "";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 20 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_availableGroups_input_category: orbatCreator_RscCombo {
            idc = 11017;
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_availableGroups_list_groups: orbatCreator_RscListbox {
            idc = 11018;
            style = 16 + 0x20;
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 4.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 12 * GUI_GRID_H;
        };

        class groupEditor_availableGroups_button_1: orbatCreator_RscButton {
            idc = 11019;
            text = "";
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 17 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };
        class groupEditor_availableGroups_button_2: orbatCreator_RscButton {
            idc = 11020;
            text = "";
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 18.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };
        class groupEditor_availableGroups_button_3: orbatCreator_RscButton {
            idc = 11021;
            text = "";
            x = 40 * GUI_GRID_W + GUI_GRID_X;
            y = 20 * GUI_GRID_H + GUI_GRID_Y;
            w = 13.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
        };

        class groupEditor_selectedGroup_list_units: orbatCreator_RscListbox {
            idc = 11022;
            x = 2.5 * GUI_GRID_W + GUI_GRID_X;
            y = 23.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 27 * GUI_GRID_W;
            h = 6 * GUI_GRID_H;
            sizeEx = 0.85 * GUI_GRID_H;
        };

        class groupEditor_selectedGroup_button_1: orbatCreator_RscButton {
            idc = 11023;
            text = "";
            x = 30 * GUI_GRID_W + GUI_GRID_X;
            y = 24 * GUI_GRID_H + GUI_GRID_Y;
            w = 7.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class groupEditor_selectedGroup_button_2: orbatCreator_RscButton {
            idc = 11024;
            text = "";
            x = 30 * GUI_GRID_W + GUI_GRID_X;
            y = 25.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 7.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
        };
        class groupEditor_selectedGroup_button_3: orbatCreator_RscButton {
            idc = 11025;
            text = "";
            x = 30 * GUI_GRID_W + GUI_GRID_X;
            y = 27 * GUI_GRID_H + GUI_GRID_Y;
            w = 7.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            sizeEx = 0.8 * GUI_GRID_H;
        };
        class groupEditor_selectedGroup_button_4: orbatCreator_RscButton {
            idc = 11026;
            text = "";
            x = 30 * GUI_GRID_W + GUI_GRID_X;
            y = 28.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 7.5 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            sizeEx = 0.8 * GUI_GRID_H;
        };

    };
};


// create grouping





// edit group


