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
            canDrag = 1;
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

        class groupEditor_selectedGroup_input_unitRank: orbatCreator_RscCombo {
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


// create group


class ALiVE_orbatCreator_interface_createGroup {
    idd = 12000;

    class controlsBackground {

        class createGroup_background: orbatCreator_RscText {
            idc = 12001;

            x = 8 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 21 * GUI_GRID_W;
            h = 17 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * GUI_GRID_H;
        };

        class createGroup_header: orbatCreator_RscText {
            idc = 12002;

            text = "Create Group";
            x = 8 * GUI_GRID_W + GUI_GRID_X;
            y = 3.05 * GUI_GRID_H + GUI_GRID_Y;
            w = 21 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",1};
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_name_title: orbatCreator_RscText {
            idc = 12003;

            text = "Name";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 5 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_classname_title: orbatCreator_RscText {
            idc = 12004;

            text = "Classname";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_category_title: orbatCreator_RscText {
            idc = 12005;

            text = "Category";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 12 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 2.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_instructions: orbatCreator_RscStructuredText {
            idc = 12011;
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 15 * GUI_GRID_H + GUI_GRID_Y;
            w = 19 * GUI_GRID_W;
            h = 5 * GUI_GRID_H;
        };

    };

    class controls {

        class createGroup_input_name: orbatCreator_RscEdit {
            idc = 12006;

            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 5.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_classname: orbatCreator_RscEdit {
            idc = 12007;

            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 8.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_category: orbatCreator_RscCombo {
            idc = 12008;
            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 12.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_button_confirm: orbatCreator_RscButton {
            idc = 12009;
            text = "Confirm";
            x = 19 * GUI_GRID_W + GUI_GRID_X;
            y = 21.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

        class createGroup_input_button_cancel: orbatCreator_RscButton {
            idc = 12010;
            text = "Cancel";
            x = 8 * GUI_GRID_W + GUI_GRID_X;
            y = 21.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {0,0,0,1};
        };

        class createGroup_input_button_autogen_classname: orbatCreator_RscButtonBig {
            idc = 12012;
            text = "Autogen Classname";
            x = 15 * GUI_GRID_W + GUI_GRID_X;
            y = 10 * GUI_GRID_H + GUI_GRID_Y;
            w = 13 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };
};


// edit group


class ALiVE_orbatCreator_interface_editGroup : ALiVE_orbatCreator_interface_createGroup {

    class controlsBackground {

        class createGroup_background: orbatCreator_RscText {
            idc = 12001;

            x = 8 * GUI_GRID_W + GUI_GRID_X;
            y = 4 * GUI_GRID_H + GUI_GRID_Y;
            w = 21 * GUI_GRID_W;
            h = 17 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * GUI_GRID_H;
        };

        class createGroup_header: orbatCreator_RscText {
            idc = 12002;

            text = "Edit Group";
            x = 8 * GUI_GRID_W + GUI_GRID_X;
            y = 3.05 * GUI_GRID_H + GUI_GRID_Y;
            w = 21 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",1};
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_name_title: orbatCreator_RscText {
            idc = 12003;

            text = "Name";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 5 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_classname_title: orbatCreator_RscText {
            idc = 12004;

            text = "Classname";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_input_category_title: orbatCreator_RscText {
            idc = 12005;

            text = "Category";
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 12 * GUI_GRID_H + GUI_GRID_Y;
            w = 6 * GUI_GRID_W;
            h = 2.5 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class createGroup_instructions: orbatCreator_RscStructuredText {
            idc = 12011;
            x = 9 * GUI_GRID_W + GUI_GRID_X;
            y = 15 * GUI_GRID_H + GUI_GRID_Y;
            w = 19 * GUI_GRID_W;
            h = 5 * GUI_GRID_H;
        };

    };

};