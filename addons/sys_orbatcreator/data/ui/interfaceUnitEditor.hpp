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

        class unitEditor_title_customUnits: orbatCreator_RscText {
            idc = 9016;
            style = 0 + 0x02;

            text = "Custom Units";
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 1.45 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.75 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };

    class controls {

        class unitEditor_combo_faction: orbatCreator_RscCombo {
            idc = 9007;
            x = -7.5 * GUI_GRID_W + GUI_GRID_X;
            y = -2.6 * GUI_GRID_H + GUI_GRID_Y;
            w = 10 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.04;
        };

        class unitEditor_button_big_one: orbatCreator_RscButtonBig {
            idc = 9008;

            text = "";
            x = 18.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_big_two: orbatCreator_RscButtonBig {
            idc = 9009;

            text = "";
            x = 30.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_big_three: orbatCreator_RscButtonBig {
            idc = 9010;

            text = "";
            x = 42.5 * GUI_GRID_W + GUI_GRID_X;
            y = -3 * GUI_GRID_H + GUI_GRID_Y;
            w = 11 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_list_unitClasses: orbatCreator_RscListBox {
            idc = 9011;
            style = 16 + 0x20;
            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 16.3 * GUI_GRID_H;
            colorBorder[] = {0,0,0,1};
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_button_unitClasses_one: orbatCreator_RscButton {
            idc = 9012;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 19.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_two: orbatCreator_RscButton {
            idc = 9013;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 21 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_three: orbatCreator_RscButton {
            idc = 9014;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_four: orbatCreator_RscButton {
            idc = 9015;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 24 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_five: orbatCreator_RscButton {
            idc = 9017;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 25.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_button_unitClasses_six: orbatCreator_RscButton {
            idc = 9018;

            x = -13.5 * GUI_GRID_W + GUI_GRID_X;
            y = 27 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 1 * GUI_GRID_H;
        };

    };
};


// create unit


class ALiVE_orbatCreator_interface_createUnit {
    idd = 10000;

    class controlsBackground {

        class unitEditor_createUnit_background: orbatCreator_RscText {
            idc = 10001;
            x = 4 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 35 * GUI_GRID_W;
            h = 22.5 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_header: orbatCreator_RscText {
            idc = 10002;
            text = "Create Unit";
            x = 4 * GUI_GRID_W + GUI_GRID_X;
            y = 1.05 * GUI_GRID_H + GUI_GRID_Y;
            w = 35 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",0.7};
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_createUnit_header_divider_center: orbatCreator_RscText {
            idc = 10003;
            x = 22 * GUI_GRID_W + GUI_GRID_X;
            y = 2.4 * GUI_GRID_H + GUI_GRID_Y;
            w = 0.05 * GUI_GRID_W;
            h = 21.2 * GUI_GRID_H;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_createUnit_input_title_name: orbatCreator_RscText {
            idc = 1003;
            text = "Name";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_classname: orbatCreator_RscText {
            idc = 10004;
            text = "Classname";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_side: orbatCreator_RscText {
            idc = 10005;
            text = "Side";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_faction: orbatCreator_RscText {
            idc = 10006;
            text = "Faction";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 14 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_header_unittype: orbatCreator_RscText {
            idc = 10007;
            text = "Unit Type";
            x = 28 * GUI_GRID_W + GUI_GRID_X;
            y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1.3 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_unittype_side: orbatCreator_RscText {
            idc = 10008;
            text = "Side";
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_unittype_faction: orbatCreator_RscText {
            idc = 10009;
            text = "Faction";
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 9 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_instructions: orbatCreator_RscStructuredText {
            idc = 10020;
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 6.5 * GUI_GRID_H;
        };

    };

    class controls {

        class unitEditor_createUnit_input_field_name: orbatCreator_RscEdit {
            idc = 10010;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 3.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.0325;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_classname: orbatCreator_RscEdit {
            idc = 10011;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 6.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            sizeEx = 0.0325;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_side: orbatCreator_RscCombo {
            idc = 10012;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 11.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_faction: orbatCreator_RscCombo {
            idc = 10013;
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 14.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_side: orbatCreator_RscCombo {
            idc = 10014;
            x = 27.5 * GUI_GRID_W + GUI_GRID_X;
            y = 6.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_faction: orbatCreator_RscCombo {
            idc = 10015;
            x = 27.5 * GUI_GRID_W + GUI_GRID_X;
            y = 9.15 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_category: orbatCreator_RscCombo {
            idc = 10021;
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_units: orbatCreator_RscListbox {
            idc = 10016;
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 15 * GUI_GRID_W;
            h = 11 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_button_cancel: orbatCreator_RscButton {
            idc = 10017;
            text = "Cancel";
            x = 4 * GUI_GRID_W + GUI_GRID_X;
            y = 24.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 17.75 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_button_confirm: orbatCreator_RscButton {
            idc = 10018;
            text = "Confirm";
            x = 22.25 * GUI_GRID_W + GUI_GRID_X;
            y = 24.75 * GUI_GRID_H + GUI_GRID_Y;
            w = 16.75 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_button_autogen_classname: orbatCreator_RscButtonBig {
            idc = 10019;
            text = "Autogenerate Classname";
            x = 10 * GUI_GRID_W + GUI_GRID_X;
            y = 8 * GUI_GRID_H + GUI_GRID_Y;
            w = 10.5 * GUI_GRID_W;
            h = 1.25 * GUI_GRID_H;
            colorBackground[] = {0.2,0.2,0.2,1};
            sizeEx = 0.85 * GUI_GRID_H;
        };

    };
};

class ALiVE_orbatCreator_interface_editUnit : ALiVE_orbatCreator_interface_createUnit {

    class controlsBackground {

        class unitEditor_createUnit_background: orbatCreator_RscText {
            idc = 10001;
            x = 4 * GUI_GRID_W + GUI_GRID_X;
            y = 2 * GUI_GRID_H + GUI_GRID_Y;
            w = 35 * GUI_GRID_W;
            h = 22 * GUI_GRID_H;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_header: orbatCreator_RscText {
            idc = 10002;
            text = "Edit Unit";
            x = 4 * GUI_GRID_W + GUI_GRID_X;
            y = 1.05 * GUI_GRID_H + GUI_GRID_Y;
            w = 35 * GUI_GRID_W;
            h = 1 * GUI_GRID_H;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",0.7};
            sizeEx = 1 * GUI_GRID_H;
        };

        class unitEditor_createUnit_header_divider_center: orbatCreator_RscText {
            idc = 10003;
            x = 22 * GUI_GRID_W + GUI_GRID_X;
            y = 2.4 * GUI_GRID_H + GUI_GRID_Y;
            w = 0.05 * GUI_GRID_W;
            h = 21.2 * GUI_GRID_H;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_createUnit_input_title_name: orbatCreator_RscText {
            idc = 1003;
            text = "Name : ";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 3 * GUI_GRID_H + GUI_GRID_Y;
            w = 4.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_classname: orbatCreator_RscText {
            idc = 10004;
            text = "Classname";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_side: orbatCreator_RscText {
            idc = 10005;
            text = "Side";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 11 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_faction: orbatCreator_RscText {
            idc = 10006;
            text = "Faction";
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 14 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_header_unittype: orbatCreator_RscText {
            idc = 10007;
            text = "Unit Type";
            x = 28 * GUI_GRID_W + GUI_GRID_X;
            y = 2.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 5.5 * GUI_GRID_W;
            h = 2 * GUI_GRID_H;
            sizeEx = 1.3 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_unittype_side: orbatCreator_RscText {
            idc = 10008;
            text = "Side";
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 6 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_input_title_unittype_faction: orbatCreator_RscText {
            idc = 10009;
            text = "Faction";
            x = 23 * GUI_GRID_W + GUI_GRID_X;
            y = 9 * GUI_GRID_H + GUI_GRID_Y;
            w = 5 * GUI_GRID_W;
            h = 1.5 * GUI_GRID_H;
        };

        class unitEditor_createUnit_instructions: orbatCreator_RscStructuredText {
            idc = 10020;
            x = 4.5 * GUI_GRID_W + GUI_GRID_X;
            y = 16.5 * GUI_GRID_H + GUI_GRID_Y;
            w = 16 * GUI_GRID_W;
            h = 6.5 * GUI_GRID_H;
        };

    };

};