#define _SX (safeZoneX+safeZoneW/2) // screen centre x
#define _BH 0.033*safeZoneH // button height
#define _captionHgt 0.75

class CBA_flexiMenu_rscPopup {
    class listButton;
    class controls {
        class caption;
        class caption2;
    };
};
class alive_flexiMenu_rscPopup: CBA_flexiMenu_rscPopup {
    onLoad = QUOTE(with uiNamespace do {CBA_ui_display = _this select 0};);
    onUnload = QUOTE(with uiNamespace do {CBA_ui_display = displayNull};);

    class listButton: listButton {
        h = _BH;
        color[] = {1, 1, 1, 1};
        color2[] = {1, 1, 1, 1}; //{1, 1, 1, 0.4};
        colorbackground2[] = {1, 1, 1, 0.4}; //{1, 1, 1, 0.4};
        colorDisabled[] = {0.5, 0.5, 0.5, 0.4};

        animTextureNormal = "x\alive\addons\ui\flexiMenu\data\popup\normal.paa";
        animTextureDisabled = "x\alive\addons\ui\flexiMenu\data\popup\disabled.paa";
        animTextureOver = "x\alive\addons\ui\flexiMenu\data\popup\over.paa";
        animTextureFocused = "x\alive\addons\ui\flexiMenu\data\popup\focused.paa";
        animTexturePressed = "x\alive\addons\ui\flexiMenu\data\popup\down.paa";
        animTextureDefault = "x\alive\addons\ui\flexiMenu\data\popup\default.paa";
        animTextureNoShortcut = "x\alive\addons\ui\flexiMenu\data\popup\normal.paa";

        class Attributes {
            font = "PuristaLight";
            color = "#FF0000";
            align = "left";
        };
    };

    class controls: controls {
        class caption: caption {
            sizeEx = _BH*_captionHgt;
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0.7};
        };
#define ExpandMacro_RowControls(ID) \
    class button##ID: listButton\
    {\
        idc = _flexiMenu_baseIDC_button+ID;\
        y = safeZoneY+0.30*safeZoneH+##ID*_BH;\
    }

        ExpandMacro_RowControls(00);
        ExpandMacro_RowControls(01);
        ExpandMacro_RowControls(02);
        ExpandMacro_RowControls(03);
        ExpandMacro_RowControls(04);
        ExpandMacro_RowControls(05);
        ExpandMacro_RowControls(06);
        ExpandMacro_RowControls(07);
        ExpandMacro_RowControls(08);
        ExpandMacro_RowControls(09);
        ExpandMacro_RowControls(10);
        ExpandMacro_RowControls(11);
        ExpandMacro_RowControls(12);
        ExpandMacro_RowControls(13);
        ExpandMacro_RowControls(14);
        ExpandMacro_RowControls(15);
        ExpandMacro_RowControls(16);
        ExpandMacro_RowControls(17);
        ExpandMacro_RowControls(18);
        ExpandMacro_RowControls(19);
        class caption2: caption2 {
            sizeEx = _BH*_captionHgt;
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0.7};
        };
#define ExpandMacro_ListControls(ID)\
    class listButton##ID: listButton\
    {\
        idc = _flexiMenu_baseIDC_listButton+ID;\
        x = _SX;\
        y = safeZoneY+0.30*safeZoneH+_BH+##ID*_BH;\
        w = 0;\
    }

        ExpandMacro_ListControls(00);
        ExpandMacro_ListControls(01);
        ExpandMacro_ListControls(02);
        ExpandMacro_ListControls(03);
        ExpandMacro_ListControls(04);
        ExpandMacro_ListControls(05);
        ExpandMacro_ListControls(06);
        ExpandMacro_ListControls(07);
        ExpandMacro_ListControls(08);
        ExpandMacro_ListControls(09);
        ExpandMacro_ListControls(10);
        ExpandMacro_ListControls(11);
        ExpandMacro_ListControls(12);
        ExpandMacro_ListControls(13);
        ExpandMacro_ListControls(14);
        ExpandMacro_ListControls(15);
        ExpandMacro_ListControls(16);
        ExpandMacro_ListControls(17);
        ExpandMacro_ListControls(18);
        ExpandMacro_ListControls(19);
    };
};

#undef _SX
#undef _BH
#undef _captionHgt
#undef ExpandMacro_RowControls
#undef ExpandMacro_ListControls
