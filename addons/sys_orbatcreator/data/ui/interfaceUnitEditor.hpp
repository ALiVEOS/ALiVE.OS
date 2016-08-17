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
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.09 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class displayName_input : orbatCreator_RscEdit {
                    idc = 10012;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.095 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10013;
                    text = "Class Name";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.145 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class className_input : orbatCreator_RscEdit {
                    idc = 10014;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.15 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class className_button_generateClassname : orbatCreator_RscButton {
                    idc = 10015;
                    text = "Generate Classname";
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.205 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.036 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class ownership_divider : orbatCreator_RscText {
                    idc = 10016;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.277 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class ownership_title : orbatCreator_common_popup_attribute_title {
                    idc = 10017;
                    text = "Ownership";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.287 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10018;
                    text = "Side";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.357 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class side_input : orbatCreator_RscCombo {
                    idc = 10019;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.362 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class faction_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10020;
                    text = "Faction";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.417 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class faction_input : orbatCreator_RscCombo {
                    idc = 10021;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.422 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_divider : orbatCreator_RscText {
                    idc = 10022;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.492 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_GREY_TITLE_HARD;
                };

                class unittype_title : orbatCreator_common_popup_attribute_title {
                    idc = 10023;
                    text = "Unit Type";
                    x = 0.21 * safezoneW + safezoneX;
                    y = 0.502 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_side_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10024;
                    text = "Side";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.572 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_side_input : orbatCreator_RscCombo {
                    idc = 10025;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.577 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_faction_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10026;
                    text = "Faction";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.632 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_faction_input : orbatCreator_RscCombo {
                    idc = 10027;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.637 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_category_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10028;
                    text = "Category";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.692 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_category_input : orbatCreator_RscCombo {
                    idc = 10029;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.697 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.03 * safezoneH;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class unittype_typeList_title : orbatCreator_common_popup_attribute_subtitle {
                    idc = 10030;
                    text = "Type";
                    x = 0.27 * safezoneW + safezoneX;
                    y = 0.752 * safezoneH;
                    w = 0.125 * safezoneW;
                    h = 0.035 * safezoneH;
                };

                class unittype_typeList_input : orbatCreator_RscListBox {
                    idc = 10031;
                    x = 0.41 * safezoneW + safezoneX;
                    y = 0.757 * safezoneH;
                    w = 0.225 * safezoneW;
                    h = 0.18 * safezoneH;
                    sizeEx = BASE_SIZE_TEXT * 0.85;
                    colorBackground[] = COLOR_BLACK_HARD;
                };

                class scroll_dummy : orbatCreator_RscText {
                    idc = 10032;
                    text = "";
                    x = 0.2 * safezoneW + safezoneX;
                    y = 0.975 * safezoneH;
                    w = 0.46 * safezoneW;
                    h = 0.00125 * safezoneH;
                    colorBackground[] = COLOR_BLACK(0);
                };

            };
        };

    };
};

class ALiVE_orbatCreator_interface_editUnit : ALiVE_orbatCreator_interface_createUnit {

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