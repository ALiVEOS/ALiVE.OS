class ALiVE_orbatCreator_interface_unitEditor {
    idd = 9000;

    class controlsBackground {

        // common header controls

        class header_background : orbatCreator_common_header_green {
            idc = 9019;
        };
        class header_interfaceTitle : orbatCreator_common_header_interfaceTitle {
            idc = 9020;
            text = "Unit Editor";
        };
        class header_banner : orbatCreator_common_header_banner {
            idc = 9021;
        };

        // standard controls

        class unitEditor_title_faction: orbatCreator_RscText {
            idc = 9004;
            text = "Faction:";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.094 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {-1,-1,-1,0};
        };

        class unitEditor_title_customUnits: orbatCreator_RscText {
            idc = 9016;
            style = 0 + 0x02;

            text = "Custom Units";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.192 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };

    class controls {

        // common header controls

        class header_menuStrip : orbatCreator_common_header_menuStrip {};

        class unitEditor_combo_faction: orbatCreator_RscCombo {
            idc = 9007;
            x = 0.0989583 * safezoneW + safezoneX;
            y = 0.108 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
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

        class unitEditor_button_unitClasses_one: orbatCreator_RscButtonBig {
            idc = 9012;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.696 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_two: orbatCreator_RscButtonBig {
            idc = 9013;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.738 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_three: orbatCreator_RscButtonBig {
            idc = 9014;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.78 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_four: orbatCreator_RscButtonBig {
            idc = 9015;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.822 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_five: orbatCreator_RscButtonBig {
            idc = 9017;

            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.864 * safezoneH + safezoneY;
            w = 0.233333 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class unitEditor_button_unitClasses_six: orbatCreator_RscButtonBig {
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

        // common controls

        class background_grid : orbatCreator_common_backgroundGrid {
            idc = 10001;
        };

        class header : orbatCreator_common_popup_header {
            idc = 10002;
            text = "Create Unit";
        };

        class background : orbatCreator_common_popup_background {
            idc = 10003;
        };

        class footer : orbatCreator_common_popup_footer {
            idc = 10004;
        };

        class context : orbatCreator_common_popup_context {
            idc = 10005;
        };

        // standard controls

    };

    class controls {

        // common controls

        class buttonOk : orbatCreator_common_popup_ok {
            idc = 10006;
        };

        class buttonCancel : orbatCreator_common_popup_cancel {
            idc = 10007;
        };

        // standard controls

        class controlsGroup_attributes : orbatCreator_common_popup_controlsGroup {
            idc = 10008;

            class controls {

                class general_divider : orbatCreator_RscText {
                    idc = 10009;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.01 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class properties_title : orbatCreator_common_popup_attribute_title {
                    idc = 10010;
                    text = "General";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.02 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10011;
                    text = "Display Name";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.09 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_input : orbatCreator_RscEdit {
                    idc = 10012;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.095 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10013;
                    text = "Class Name";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.145 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class className_input : orbatCreator_RscEdit {
                    idc = 10014;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.15 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class ownership_divider : orbatCreator_RscText {
                    idc = 10015;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.222 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class ownership_title : orbatCreator_common_popup_attribute_title {
                    idc = 10016;
                    text = "Ownership";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.232 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10017;
                    text = "Side";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.302 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_input : orbatCreator_RscCombo {
                    idc = 10018;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.307 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class faction_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10019;
                    text = "Faction";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.362 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class faction_input : orbatCreator_RscCombo {
                    idc = 10020;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.367 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_divider : orbatCreator_RscText {
                    idc = 10021;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.439 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class unittype_title : orbatCreator_common_popup_attribute_title {
                    idc = 10022;
                    text = "Unit Type";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.449 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10023;
                    text = "Side";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.519 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_side_input : orbatCreator_RscCombo {
                    idc = 10024;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.524 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_faction_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10025;
                    text = "Faction";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.579 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_faction_input : orbatCreator_RscCombo {
                    idc = 10026;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.584 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_category_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10027;
                    text = "Category";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.639 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_category_input : orbatCreator_RscCombo {
                    idc = 10028;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.644 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_typeList_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10029;
                    text = "Type";
                    x = 0.29 * safezoneW + safezoneX;
                    y = 0.699 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_typeList_input : orbatCreator_RscListBox {
                    idc = 10030;
                    x = 0.43 * safezoneW + safezoneX;
                    y = 0.704 * safezoneH;
                    w = 0.20 * safezoneW;
                    h = 0.15 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

            };
        };

    };
};

/*
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
*/

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


// edit vehicle


class ALiVE_orbatCreator_interface_editVehicle {
    idd = 13000;

    class controlsBackground {

        class unitEditor_editVehicle_bottom_controlbar_background: orbatCreator_RscText {
            idc = 13001;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.934 * safezoneH + safezoneY;
            w = 0.969792 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_editVehicle_left_icon_one: orbatCreator_RscPicture {
            idc = 13002;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.024 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_editVehicle_left_icon_two: orbatCreator_RscPicture {
            idc = 13003;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.122 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

        class unitEditor_editVehicle_left_icon_three: orbatCreator_RscPicture {
            idc = 13004;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {1,1,1,1};
        };

    };

    class controls {

        class unitEditor_editVehicle_left_button_one: orbatCreator_RscButton {
            idc = 13006;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.024 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0,0,0,0.5};
        };

        class unitEditor_editVehicle_left_button_two: orbatCreator_RscButton {
            idc = 13007;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.122 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0,0,0,0.5};
        };

        class unitEditor_editVehicle_left_button_three: orbatCreator_RscButton {
            idc = 13008;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.04375 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0,0,0,0.5};
        };

        class unitEditor_editVehicle_left_list_one: orbatCreator_RscListbox {
            idc = 13005;
            x = 0.0625 * safezoneW + safezoneX;
            y = 0.024 * safezoneH + safezoneY;
            w = 0.211458 * safezoneW;
            h = 0.434 * safezoneH;
        };

        class unitEditor_editVehicle_left_list_two: orbatCreator_RscListBox {
            idc = 13012;

            x = 0.0625 * safezoneW + safezoneX;
            y = 0.122 * safezoneH + safezoneY;
            w = 0.211458 * safezoneW;
            h = 0.434 * safezoneH;
        };

        class unitEditor_editVehicle_left_list_three: orbatCreator_RscListBox {
            idc = 13013;

            x = 0.0625 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.211458 * safezoneW;
            h = 0.434 * safezoneH;
        };

        class unitEditor_editVehicle_bottom_controlbar_cancel: orbatCreator_RscButton {
            idc = 13009;
            text = "Cancel Changes";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.934 * safezoneH + safezoneY;
            w = 0.175 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class unitEditor_editVehicle_bottom_controlbar_save: orbatCreator_RscButton {
            idc = 13011;
            text = "Save Changes";
            x = 0.80625 * safezoneW + safezoneX;
            y = 0.934 * safezoneH + safezoneY;
            w = 0.175 * safezoneW;
            h = 0.035 * safezoneH;
        };

    };
};