class ALiVE_orbatCreator_interface_groupEditor {
    idd = 11000;

    class controlsBackground {

        class groupEditor_header : orbatCreator_RscText {
            idc = 11001;

            text = "";
            x = -0.003125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 1.00625 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0.576,0.769,0.49,1};
        };

        class groupEditor_header_title : orbatCreator_RscText {
            idc = 11002;

            text = "Group Editor";
            x = 0.0078125 * safezoneW + safezoneX;
            y = -0.00399999 * safezoneH + safezoneY;
            w = 0.21875 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class groupEditor_headerLogo : orbatCreator_RscPicture {
            idc = 11003;
            style = 48;
            text = "\x\alive\addons\sys_orbatcreator\data\images\banner_alive.paa";
            x = 0.653125 * safezoneW + safezoneX;
            y = -0.00315998 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.05544 * safezoneH;
        };

        class groupEditor_title_faction : orbatCreator_RscText {
            idc = 11004;
            text = "Faction:";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.0632 * safezoneH + safezoneY;
            w = 0.0802083 * safezoneW;
            h = 0.056 * safezoneH;
            colorBackground[] = {-1,-1,-1,0};
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
        };

        class groupEditor_availableAssets_header: orbatCreator_RscText {
            idc = 11005;
            style = 0 + 0x02;
            text = "Available Assets";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.185 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0,0,0,1};
        };

        class groupEditor_availableGroups_header: orbatCreator_RscText {
            idc = 11006;
            style = 0 + 0x02;
            text = "Groups";
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.185 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0,0,0,1};
        };

        class groupEditor_selectedGroup_header: orbatCreator_RscText {
            idc = 11007;
            text = "Selected Group";
            x = 0.244792 * safezoneW + safezoneX;
            y = 0.78 * safezoneH + safezoneY;
            w = 0.510417 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0,0,0,1};
        };

    };

    class controls {

        class groupEditor_combo_faction : orbatCreator_RscCombo {
            idc = 11008;
            x = 0.0989583 * safezoneW + safezoneX;
            y = 0.0772 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_button_big_one : orbatCreator_RscButtonBig {
            idc = 11009;

            text = "";
            x = 0.478125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class groupEditor_button_big_two : orbatCreator_RscButtonBig {
            idc = 11010;

            text = "";
            x = 0.653125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class groupEditor_button_big_three : orbatCreator_RscButtonBig {
            idc = 11011;

            text = "";
            x = 0.828125 * safezoneW + safezoneX;
            y = 0.066 * safezoneH + safezoneY;
            w = 0.160417 * safezoneW;
            h = 0.056 * safezoneH;
        };

        class groupEditor_availableAssets_input_category: orbatCreator_RscCombo {
            idc = 11012;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.227 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_availableAssets_list_units: orbatCreator_RscListbox {
            idc = 11013;
            canDrag = 1;
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.276 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.336 * safezoneH;
        };

        class groupEditor_availableAssets_button_1: orbatCreator_RscButton {
            idc = 11014;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.626 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_availableAssets_button_2: orbatCreator_RscButton {
            idc = 11015;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.668 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_availableAssets_button_3: orbatCreator_RscButton {
            idc = 11016;
            text = "";
            x = 0.0114583 * safezoneW + safezoneX;
            y = 0.71 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_availableGroups_input_category: orbatCreator_RscCombo {
            idc = 11017;
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.234 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_availableGroups_list_groups: orbatCreator_RscListbox {
            idc = 11018;
            style = 16 + 0x20;
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.276 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.336 * safezoneH;
        };

        class groupEditor_availableGroups_button_1: orbatCreator_RscButton {
            idc = 11019;
            text = "";
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.626 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class groupEditor_availableGroups_button_2: orbatCreator_RscButton {
            idc = 11020;
            text = "";
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.668 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };
        class groupEditor_availableGroups_button_3: orbatCreator_RscButton {
            idc = 11021;
            text = "";
            x = 0.791667 * safezoneW + safezoneX;
            y = 0.71 * safezoneH + safezoneY;
            w = 0.196875 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class groupEditor_selectedGroup_list_units: orbatCreator_RscListbox {
            idc = 11022;
            x = 0.244792 * safezoneW + safezoneX;
            y = 0.808 * safezoneH + safezoneY;
            w = 0.39375 * safezoneW;
            h = 0.168 * safezoneH;
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
        };

        class groupEditor_selectedGroup_input_unitRank: orbatCreator_RscCombo {
            idc = 11023;
            text = "";
            x = 0.645833 * safezoneW + safezoneX;
            y = 0.822 * safezoneH + safezoneY;
            w = 0.109375 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class groupEditor_selectedGroup_button_2: orbatCreator_RscButton {
            idc = 11024;
            text = "";
            x = 0.645833 * safezoneW + safezoneX;
            y = 0.864 * safezoneH + safezoneY;
            w = 0.109375 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class groupEditor_selectedGroup_button_3: orbatCreator_RscButton {
            idc = 11025;
            text = "";
            x = 0.645833 * safezoneW + safezoneX;
            y = 0.906 * safezoneH + safezoneY;
            w = 0.109375 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
        };

        class groupEditor_selectedGroup_button_4: orbatCreator_RscButton {
            idc = 11026;
            text = "";
            x = 0.645833 * safezoneW + safezoneX;
            y = 0.948 * safezoneH + safezoneY;
            w = 0.109375 * safezoneW;
            h = 0.028 * safezoneH;
            sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
        };

    };
};


// create group


class ALiVE_orbatCreator_interface_createGroup {
    idd = 12000;

    class controlsBackground {

        class createGroup_background: orbatCreator_RscText {
            idc = 12001;

            x = 0.325 * safezoneW + safezoneX;
            y = 0.262 * safezoneH + safezoneY;
            w = 0.30625 * safezoneW;
            h = 0.476 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class createGroup_header: orbatCreator_RscText {
            idc = 12002;

            text = "Create Group";
            x = 0.325 * safezoneW + safezoneX;
            y = 0.2354 * safezoneH + safezoneY;
            w = 0.30625 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",1};
        };

        class createGroup_input_name_title: orbatCreator_RscText {
            idc = 12003;

            text = "Name";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.29 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class createGroup_input_classname_title: orbatCreator_RscText {
            idc = 12004;

            text = "Classname";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.374 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class createGroup_input_category_title: orbatCreator_RscText {
            idc = 12005;

            text = "Category";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.486 * safezoneH + safezoneY;
            w = 0.0875 * safezoneW;
            h = 0.07 * safezoneH;
        };

        class createGroup_input_icon_title: orbatCreator_RscText {
            idc = 12013;

            text = "Icon";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.0875 * safezoneW;
            h = 0.07 * safezoneH;
        };

        class createGroup_instructions: orbatCreator_RscStructuredText {
            idc = 12011;
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.654 * safezoneH + safezoneY;
            w = 0.277083 * safezoneW;
            h = 0.056 * safezoneH;
        };

    };

    class controls {

        class createGroup_input_name: orbatCreator_RscEdit {
            idc = 12006;

            x = 0.427083 * safezoneW + safezoneX;
            y = 0.2942 * safezoneH + safezoneY;
            w = 0.189583 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_classname: orbatCreator_RscEdit {
            idc = 12007;

            x = 0.427083 * safezoneW + safezoneX;
            y = 0.3782 * safezoneH + safezoneY;
            w = 0.189583 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_category: orbatCreator_RscCombo {
            idc = 12008;
            x = 0.427083 * safezoneW + safezoneX;
            y = 0.507 * safezoneH + safezoneY;
            w = 0.189583 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_button_confirm: orbatCreator_RscButton {
            idc = 12009;
            text = "Confirm";
            x = 0.485417 * safezoneW + safezoneX;
            y = 0.752 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0,0,0,1};
        };

        class createGroup_input_button_cancel: orbatCreator_RscButton {
            idc = 12010;
            text = "Cancel";
            x = 0.325 * safezoneW + safezoneX;
            y = 0.752 * safezoneH + safezoneY;
            w = 0.145833 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {0,0,0,1};
        };

        class createGroup_input_button_autogen_classname: orbatCreator_RscButtonBig {
            idc = 12012;
            text = "Autogen Classname";
            x = 0.427083 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.189583 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

        class createGroup_input_icon_combo: orbatCreator_RscCombo {
            idc = 12014;
            x = 0.427083 * safezoneW + safezoneX;
            y = 0.591 * safezoneH + safezoneY;
            w = 0.189583 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };

    };
};


// edit group


class ALiVE_orbatCreator_interface_editGroup : ALiVE_orbatCreator_interface_createGroup {

    class controlsBackground {

        class createGroup_background: orbatCreator_RscText {
            idc = 12001;

            x = 0.325 * safezoneW + safezoneX;
            y = 0.262 * safezoneH + safezoneY;
            w = 0.30625 * safezoneW;
            h = 0.476 * safezoneH;
            colorBackground[] = {-1,-1,-1,1};
        };

        class createGroup_header: orbatCreator_RscText {
            idc = 12002;

            text = "Edit Group";
            x = 0.325 * safezoneW + safezoneX;
            y = 0.2354 * safezoneH + safezoneY;
            w = 0.30625 * safezoneW;
            h = 0.028 * safezoneH;
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])",1};
        };

        class createGroup_input_name_title: orbatCreator_RscText {
            idc = 12003;

            text = "Name";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.29 * safezoneH + safezoneY;
            w = 0.065625 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class createGroup_input_classname_title: orbatCreator_RscText {
            idc = 12004;

            text = "Classname";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.374 * safezoneH + safezoneY;
            w = 0.0729167 * safezoneW;
            h = 0.042 * safezoneH;
        };

        class createGroup_input_category_title: orbatCreator_RscText {
            idc = 12005;

            text = "Category";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.486 * safezoneH + safezoneY;
            w = 0.0875 * safezoneW;
            h = 0.07 * safezoneH;
        };

        class createGroup_input_icon_title: orbatCreator_RscText {
            idc = 12013;

            text = "Icon";
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.57 * safezoneH + safezoneY;
            w = 0.0875 * safezoneW;
            h = 0.07 * safezoneH;
        };

        class createGroup_instructions: orbatCreator_RscStructuredText {
            idc = 12011;
            x = 0.339583 * safezoneW + safezoneX;
            y = 0.654 * safezoneH + safezoneY;
            w = 0.277083 * safezoneW;
            h = 0.056 * safezoneH;
        };

    };

};