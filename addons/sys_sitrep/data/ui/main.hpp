class RscText;

class RscDisplayALiVESITREP
{
    idd = 90001;
    movingEnable = 1;
    onLoad = "[_this] call ALiVE_fnc_sitrepOnLoad";
    onUnload = "";
    class controlsBackground
    {
         class SITREP_Background : RscPicture
        {
                idc = 90002;
                x = 0.142424 * GUI_GRID_WAbs + GUI_GRID_X;
                y = 0.0632 * GUI_GRID_HAbs + GUI_GRID_Y;
                w = 0.73 * GUI_GRID_WAbs;
                h = 0.84 * GUI_GRID_HAbs;
                text = "x\alive\addons\main\data\ui\ALiVE_toughbook.paa";
                moving = 1;
                colorBackground[] = {0,0,0,0};
        };
    };
    class controls
    {
        class SITREP_Map: SITREP_RscMap
        {
            idc = 1;
            x = 0.586496 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.158313 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159796 * GUI_GRID_WAbs;
            h = 0.308024 * GUI_GRID_HAbs;
        };
        class SITREP_MainTitle: SITREP_RscText
        {
            idc = 2;
            text = "SITUATION REPORT (SITREP)"; //--- ToDo: Localize;
            x = 0.263812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.162713 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159596 * GUI_GRID_WAbs;
        };
        class SITREP_Abort: SITREP_RscButton
        {
            idc = 3;
            style = 2;
            action = "if !(isNil 'ALIVE_SYS_sitrep_mapStartMarker') then {deleteMarkerLocal ALIVE_SYS_sitrep_mapStartMarker;}; closeDialog 0";
            text = "CANCEL"; //--- ToDo: Localize;
            x = 0.586496 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.742019 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159796 * GUI_GRID_WAbs;
            h = 0.0220017 * GUI_GRID_HAbs;
            colorBackground[] = {0.376,0.196,0.204,1};
            colorText[] = {0.706,0.706,0.706,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            sizeEx = 0.5 * GUI_GRID_H;
        };
        class SITREP_sendButton: SITREP_RscButton
        {
            idc = 4;
            style = 2;
            text = "SEND SITREP"; //--- ToDo: Localize;
            x = 0.586496 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.714815 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.159796 * GUI_GRID_WAbs;
            h = 0.0220017 * GUI_GRID_HAbs;
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.706,0.706,0.706,1};
            colorFocused[] = {0.706,0.706,0.706,1};
            sizeEx = 0.5 * GUI_GRID_H;
            action = "call ALiVE_fnc_sitrepButtonAction";
        };
        // #698 Terrain toggle - top-right of the header bezel (identical toughbook to the CS tablet,
        // so the same slot), clear of the map. Swaps the map between satellite and schematic.
        class SITREP_TerrainButton: SITREP_RscRealButton
        {
            idc = 40;
            x = 0.686 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.098 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0597643 * GUI_GRID_WAbs;
            h = 0.028 * GUI_GRID_HAbs;
            text = "Terrain";
            periodFocus = 1e10; // never blink (0 can fall back to the default focus-pulse)
            periodOver = 1e10;
            period = 1e10; // #698 freeze the focus blink too (period drives the pulse while focused; periodFocus/Over alone left it flashing until focus moved away)
            action = "[!(uinamespace getVariable ['SITREP_TerrainMode', true])] call ALiVE_fnc_sitrepSetTerrainMode";
            colorBackground[] = {0.384,0.439,0.341,1};
            colorBackgroundFocused[] = {0.384,0.439,0.341,1}; // stay green on focus (matches the CS Terrain button)
            colorFocused[] = {0.706,0.706,0.706,1};
            sizeEx = 0.5 * GUI_GRID_H; // 0.036 - readable label; the earlier cubed value (~0.00005) was invisible on a CT_BUTTON
        };
        class SITREP_DTGTEXT: SITREP_RscText_Right
        {
            style = 1;
            idc = 1004;

            text = "DTG:"; //--- ToDo: Localize;
            x = 0.437834 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.162713 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_DTGVALUE: RscText
        {
            idc = 5;
            sizeEx = "(            (            (            ((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
            style = 1;
            x = 0.51 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.162713 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.060421 * GUI_GRID_WAbs;
            class Attributes
            {
                font = "PuristaMedium";
                color = "#627057";
                valign = "top";
                shadow = true;
                shadowColor = "#000000";
            };
        };
        class SITREP_TextCallsign: SITREP_RscText
        {
            idc = 6;

            text = "CALLSIGN:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.225979 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_ValueCallsign: SITREP_RscEdit
        {
            idc = 7;

            x = 0.345668 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.225979 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.154641 * GUI_GRID_WAbs;
        };
        class SITREP_TextText: SITREP_RscText
        {
            idc = 8;

            text = "DATE/TIME:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.258982 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_ValueText: SITREP_RscEdit
        {
            idc = 9;

            x = 0.345668 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.258982 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_LOCTEXT: SITREP_RscText_Right
        {
            idc = 10;
            style = 1;

            text = "GRID:"; //--- ToDo: Localize;
            x = 0.427834 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.258982 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_LOCVALUE: SITREP_RscEdit
        {
            idc = 11;

            x = 0.50 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.258982 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_EKIATEXT: SITREP_RscText
        {
            idc = 12;
            text = "ENEMY KIA:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.291984 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class SITREP_EKIAVALUE: SITREP_RscEdit
        {
            idc = 13;

            x = 0.345668 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.291984 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class EN_TEXT: SITREP_RscText
        {
            idc = 14;

            text = "ENEMY STATE:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.35799 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.127817 * GUI_GRID_WAbs;
        };

        class CIV_TEXT: SITREP_RscText
        {
            idc = 18;
            text = "CIVILIAN KIA:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.324987 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.068 * GUI_GRID_WAbs;
        };
        class FKIA_TEXT: SITREP_RscText_Right
        {
            idc = 20;

            text = "FRIENDLY KIA:"; //--- ToDo: Localize;
            x = 0.427834 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.291984 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;

        };
        class FWIA_TEXT: SITREP_RscText_Right
        {
            idc = 22;

            text = "FRIENDLY WIA:"; //--- ToDo: Localize;
            x = 0.417834 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.324987 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0780421 * GUI_GRID_WAbs;

        };
        class FF_TEXT: SITREP_RscText
        {
            idc = 24;

            text = "FRIENDLY STATE:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.467998 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.138318 * GUI_GRID_WAbs;
        };
        class FWIA_VALUE: SITREP_RscEdit
        {
            idc = 23;

            x = 0.50 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.324987 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
        };
        class FKIA_VALUE: SITREP_RscEdit
        {
            idc = 21;

            x = 0.50 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.291984 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
            h = 0.0176014 * GUI_GRID_HAbs;
        };
        class SITREP_ENVALUE: SITREP_RscEdit
        {
            idc = 15;

            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.38 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.28826 * GUI_GRID_WAbs;
            h = 0.087829 * GUI_GRID_HAbs;
        };
        class SITREP_FFVALUE: SITREP_RscEdit
        {
            idc = 27;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.49 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.28826 * GUI_GRID_WAbs;
            h = 0.087829 * GUI_GRID_HAbs;
        };
        class SITREP_REMARKSTEXT: SITREP_RscText
        {
            idc = 32;
            text = "REMARKS / INTEL / OTHER:"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.578007 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.270421 * GUI_GRID_WAbs;
            h = 0.0176014 * GUI_GRID_HAbs;
        };
        class SITREP_CIVVALUE: SITREP_RscEdit
        {
            idc = 19;

            x = 0.345668 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.324987 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
            h = 0.0176014 * GUI_GRID_HAbs;
        };
        class SITREP_REMARKSVALUE: SITREP_RscEdit
        {
            idc = 33;

            text = "DO NOT USE QUOTE MARKS IN TEXT BOXES"; //--- ToDo: Localize;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.6 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.28826 * GUI_GRID_WAbs;
            h = 0.127829 * GUI_GRID_HAbs;
        };
        class SITREP_AMMOTEXT: SITREP_RscText_Right
        {
            idc = 30;
            style = 1;

            text = "AMMO:"; //--- ToDo: Localize;
            x = 0.583011 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.477998 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0637606 * GUI_GRID_WAbs;

        };
        class SITREP_CASTEXT: SITREP_RscText_Right
        {
            idc = 28;
            style = 1;

            text = "CASUALTIES:"; //--- ToDo: Localize;
            x = 0.583011 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.511001 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0637606 * GUI_GRID_WAbs;

        };
        class SITREP_AMMOLIST: SITREP_RscComboBox
        {
            idc = 31;
            x = 0.644022 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.477998 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.10002 * GUI_GRID_WAbs;
            h = 0.0203195 * GUI_GRID_HAbs;
        };
        class SITREP_CASLIST: SITREP_RscComboBox
        {
            idc = 29;
            x = 0.644022 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.511001 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.10002 * GUI_GRID_WAbs;
            h = 0.0203195 * GUI_GRID_HAbs;
        };
        class SITREP_VEHTEXT: SITREP_RscText_Right
        {
            idc = 36;
            style = 1;

            text = "VEHICLES:"; //--- ToDo: Localize;
            x = 0.563011 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.544004 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0837606 * GUI_GRID_WAbs;

        };
        class SITREP_VEHLIST: SITREP_RscComboBox
        {
            idc = 37;
            x = 0.644022 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.544004 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.10002 * GUI_GRID_WAbs;
            h = 0.0203195 * GUI_GRID_HAbs;
        };
        class SITREP_CSTEXT: SITREP_RscText_Right
        {
            idc = 38;
            style = 1;

            text = "COMBAT SPT:"; //--- ToDo: Localize;
            x = 0.563011 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.577007 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0837606 * GUI_GRID_WAbs;

        };
        class SITREP_CSLIST: SITREP_RscComboBox
        {
            idc = 39;
            x = 0.644022 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.577007 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.10002 * GUI_GRID_WAbs;
            h = 0.0203195 * GUI_GRID_HAbs;
        };
        class ALIVE_EYESTEXT: SITREP_RscText_Right
        {
            idc = 34;
            text = "EYES ONLY:"; //--- ToDo: Localize;
            style = 1;
            x = 0.283812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.742019 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.0680421 * GUI_GRID_WAbs;
            h = 0.0176014 * GUI_GRID_HAbs;
        };
        class ALIVE_EYESVALUE: SITREP_RscComboBox
        {
            idc = 35;
            x = 0.353812 * GUI_GRID_WAbs + GUI_GRID_X;
            y = 0.742019 * GUI_GRID_HAbs + GUI_GRID_Y;
            w = 0.184641 * GUI_GRID_WAbs;
            h = 0.0203195 * GUI_GRID_HAbs;
        };
    };
};
