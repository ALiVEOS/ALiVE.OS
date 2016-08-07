class ALiVE_orbatCreator_interface_unitEditor {
    idd = 9000;

    class controlsBackground {

        class unitEditor_header: orbatCreator_RscText {
            idc = 9001;

            text = "";
            x = -0.003125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 1.00625 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class unitEditor_header_title: orbatCreator_RscText {
            idc = 9002;

            text = "Unit Editor";
            x = 0.0078125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class unitEditor_headerLogo: orbatCreator_RscPicture {
            idc = 9003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 0.653125 * safezoneW + safezoneX;
            y = -0.00315998 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.05544 * safezoneH;
        };

        class unitEditor_title_faction: orbatCreator_RscText {
            idc = 9004;
            text = "Faction:";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.0632 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {-1,-1,-1,0};
        };

        class unitEditor_title_customUnits: orbatCreator_RscText {
            idc = 9016;
            style = 0 + 0x02;

            text = "Custom Units";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.1906 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.049 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };

    class controls {

        class unitEditor_combo_faction: orbatCreator_RscCombo {
            idc = 9007;
            x = 0.0989583 * safezoneW + safezoneX;
            y = 0.0772 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_big_one: orbatCreator_RscButtonBig {
            idc = 9008;

            text = "";
            x = 0.478125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class unitEditor_button_big_two: orbatCreator_RscButtonBig {
            idc = 9009;

            text = "";
            x = 0.653125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class unitEditor_button_big_three: orbatCreator_RscButtonBig {
            idc = 9010;

            text = "";
            x = 0.828125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class unitEditor_list_unitClasses: orbatCreator_RscListBox {
            idc = 9011;
            style = 16 + 0x20;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.4564 * safezoneH;
            colorBorder[] = {0,0,0,1};
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_button_unitClasses_one: orbatCreator_RscButton {
            idc = 9012;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.696 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_two: orbatCreator_RscButton {
            idc = 9013;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.738 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_three: orbatCreator_RscButton {
            idc = 9014;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.78 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_four: orbatCreator_RscButton {
            idc = 9015;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.822 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_five: orbatCreator_RscButton {
            idc = 9017;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.864 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_six: orbatCreator_RscButton {
            idc = 9018;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.906 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

    };
};


// create unit


class ALiVE_orbatCreator_interface_createUnit {
    idd = 10000;

    class controlsBackground {

        class unitEditor_createUnit_background: orbatCreator_RscText {
            idc = 10001;
            x = 0.266667 * safezoneW + safezoneX;
            y = 0.206 * safezoneH + safezoneY;
            w = 0.510417 * safezoneW;
            h = 0.63 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_header: orbatCreator_RscText {
            idc = 10002;
            text = "Create Unit";
            x = 0.266667 * safezoneW + safezoneX;
            y = 0.1794 * safezoneH + safezoneY;
            w = 0.510417 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",0.7};
        };

        class unitEditor_createUnit_header_divider_center: orbatCreator_RscText {
            idc = 10003;
            x = 0.529167 * safezoneW + safezoneX;
            y = 0.2172 * safezoneH + safezoneY;
            w = 0.000729167 * safezoneW;
            h = 0.5936 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_createUnit_input_title_name: orbatCreator_RscText {
            idc = 1003;
            text = "Name";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_classname: orbatCreator_RscText {
            idc = 10004;
            text = "Classname";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_side: orbatCreator_RscText {
            idc = 10005;
            text = "Side";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.458 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_faction: orbatCreator_RscText {
            idc = 10006;
            text = "Faction";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.542 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_header_unittype: orbatCreator_RscText {
            idc = 10007;
            text = "Unit Type";
            x = 0.616667 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.056 * safezoneH;
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.3);
        };

        class unitEditor_createUnit_input_title_unittype_side: orbatCreator_RscText {
            idc = 10008;
            text = "Side";
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_unittype_faction: orbatCreator_RscText {
            idc = 10009;
            text = "Faction";
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.402 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_instructions: orbatCreator_RscStructuredText {
            idc = 10020;
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.612 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.182 * safezoneH;
        };

    };

    class controls {

        class unitEditor_createUnit_input_field_name: orbatCreator_RscEdit {
            idc = 10010;
            x = 0.354167 * safezoneW + safezoneX;
            y = 0.2382 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_classname: orbatCreator_RscEdit {
            idc = 10011;
            x = 0.354167 * safezoneW + safezoneX;
            y = 0.3222 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_side: orbatCreator_RscCombo {
            idc = 10012;
            x = 0.354167 * safezoneW + safezoneX;
            y = 0.4622 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_faction: orbatCreator_RscCombo {
            idc = 10013;
            x = 0.354167 * safezoneW + safezoneX;
            y = 0.5462 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_side: orbatCreator_RscCombo {
            idc = 10014;
            x = 0.609375 * safezoneW + safezoneX;
            y = 0.3222 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_faction: orbatCreator_RscCombo {
            idc = 10015;
            x = 0.609375 * safezoneW + safezoneX;
            y = 0.4062 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_category: orbatCreator_RscCombo {
            idc = 10021;
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.458 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_input_field_unittype_units: orbatCreator_RscListbox {
            idc = 10016;
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.5 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.308 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class unitEditor_createUnit_button_cancel: orbatCreator_RscButton {
            idc = 10017;
            text = "Cancel";
            x = 0.266667 * safezoneW + safezoneX;
            y = 0.843 * safezoneH + safezoneY;
            w = 0.258854 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_button_confirm: orbatCreator_RscButton {
            idc = 10018;
            text = "Confirm";
            x = 0.532813 * safezoneW + safezoneX;
            y = 0.843 * safezoneH + safezoneY;
            w = 0.244271 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_button_autogen_classname: orbatCreator_RscButtonBig {
            idc = 10019;
            text = "Autogenerate Classname";
            x = 0.354167 * safezoneW + safezoneX;
            y = 0.374 * safezoneH + safezoneY;
            w = 0.153125 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
        };

    };
};

class ALiVE_orbatCreator_interface_editUnit : ALiVE_orbatCreator_interface_createUnit {

    class controlsBackground {

        class unitEditor_createUnit_background: orbatCreator_RscText {
            idc = 10001;
            x = 0.266667 * safezoneW + safezoneX;
            y = 0.206 * safezoneH + safezoneY;
            w = 0.510417 * safezoneW;
            h = 0.63 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_createUnit_header: orbatCreator_RscText {
            idc = 10002;
            text = "Edit Unit";
            x = 0.266667 * safezoneW + safezoneX;
            y = 0.1794 * safezoneH + safezoneY;
            w = 0.510417 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",0.7};
        };

        class unitEditor_createUnit_header_divider_center: orbatCreator_RscText {
            idc = 10003;
            x = 0.529167 * safezoneW + safezoneX;
            y = 0.2172 * safezoneH + safezoneY;
            w = 0.000729167 * safezoneW;
            h = 0.5936 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_createUnit_input_title_name: orbatCreator_RscText {
            idc = 1003;
            text = "Name";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_classname: orbatCreator_RscText {
            idc = 10004;
            text = "Classname";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_side: orbatCreator_RscText {
            idc = 10005;
            text = "Side";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.458 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_faction: orbatCreator_RscText {
            idc = 10006;
            text = "Faction";
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.542 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_header_unittype: orbatCreator_RscText {
            idc = 10007;
            text = "Unit Type";
            x = 0.616667 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.056 * safezoneH;
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.3);
        };

        class unitEditor_createUnit_input_title_unittype_side: orbatCreator_RscText {
            idc = 10008;
            text = "Side";
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.318 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_input_title_unittype_faction: orbatCreator_RscText {
            idc = 10009;
            text = "Faction";
            x = 0.54375 * safezoneW + safezoneX;
            y = 0.402 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class unitEditor_createUnit_instructions: orbatCreator_RscStructuredText {
            idc = 10020;
            x = 0.273958 * safezoneW + safezoneX;
            y = 0.612 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.182 * safezoneH;
        };

    };

};