#include "common.hpp"

class NEO_resourceRadio
{
        idd = 655555;
        movingEnable = true;
        onLoad = "[] spawn NEO_fnc_radioOnLoad; ";
        onUnload = "_this call NEO_fnc_radioOnUnload";

        class controlsBackground {
            //Background
            class NEO_radioBackground : RscPicture
            {
                idc = 655556;
                x = TABLET_ART_X;
                y = TABLET_ART_Y;
                w = TABLET_ART_WAbs;
                h = TABLET_ART_HAbs;
                text = "\x\alive\addons\main\data\ui\ALiVE_tablet_modern43_ca.paa"; // ALiVE_fnc_tabletOpen sets the era's artwork
                moving = 0;
                colorBackground[] = {0,0,0,0};
            };
        };

        class controls
        {
                //MAP
                class NEO_radioMap : NEO_RscMap
                {
                        idc = 655560;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1584 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.216525 * GUI_GRID_WAbs;
                        h = 0.42 * GUI_GRID_HAbs;
                };

                //Main Support Title
                class NEO_radioMainTitle : NEO_RscText
                {
                        idc = -1;
                        text = "$STR_ALIVE_CS_UI_AVAILABLE"; //--- ToDo: Localize;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1584 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.159596 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        class Attributes
                        {
                                font = "PuristaMedium";
                                color = "#B4B4B4";
                                align = "left";
                                valign = "middle";
                                shadow = true;
                                shadowColor = "#000000";
                                size = 0.8;
                        };
                };

                //Abort Button
                // Back to the C2ISTAR menu, like the other tablets (Jman 19 Oct); shares Close's old slot, and is
                // hidden by fnc_radioAction where C2ISTAR isn't in the mission
                class NEO_radioBack : NEO_RscButton
                {
                        idc = 655598;
                        text = "$STR_ALIVE_CS_UI_BACK";
                        action = "if (isNil 'ALiVE_c2istar_fnc_backToMenu') then { closeDialog 0 } else { [] call ALiVE_c2istar_fnc_backToMenu }";
                        TABLET_KEY(TABLET_KEY_RX,2); // the painted key R3 (gui_grid.hpp)
                };
                class NEO_radioAbort : NEO_RscButton
                {
                        idc = 655561;
                        text = "$STR_ALIVE_CS_UI_CLOSE";
                        action = "closeDialog 0";
                        TABLET_KEY(TABLET_KEY_RX,3); // the painted key R4 (gui_grid.hpp)
                };

                //Main Support ListBox
                class NEO_radioMainList : NEO_RscGUIListBox
                {
                        idc = 655565;
                        x = 0.271102 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1892 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.241271 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        colorBackground[] = {0.047,0.047,0.047,0.72};
                        colorActive[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //=========================
                //Transport Unit ListBox
                class NEO_radioTransportUnitList : NEO_RscGUIListBox
                {
                        idc = 655568;
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3068 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        // Category lists share screen space; only the active category
                        // receives a shaded background at runtime.
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                };

                //Transport Task ListBox
                class NEO_radioTransportTaskList : NEO_radioTransportUnitList
                {
                        idc = 655569;
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.4272 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.09 * GUI_GRID_HAbs; // ends ~0.517, clearing the sling-load message/cargo row at y=0.52 (0.15 overlapped it); boxed above by the TASK header ending ~0.4244
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                };

                //Transport Unit LB Text
                class NEO_radioTransportUnitText : NEO_RscText
                {
                        idc = 655570;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0779492 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };

                //Transport Task LB Text
                class NEO_radioTransportTaskText : NEO_radioTransportUnitText
                {
                        idc = 655571;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3936 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0742373 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };

                //Transport Help Unit Text
                class NEO_radioTransportHelpUnitText : NEO_radioTransportUnitText
                {
                        idc = 655572;
                        x = 0.351527 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.160845 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        sizeEx = 0.6 * GUI_GRID_H;
                        text = "";
                };

                //Transport Help Task Text
                class NEO_radioTransportHelpTaskText : NEO_radioTransportHelpUnitText
                {
                        idc = 655573;
                        x = 0.351525 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3936 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.160845 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        sizeEx = 0.6 * GUI_GRID_H;
                        text = "";
                };

                //Transport Confirm Button
                class NEO_radioTransportConfirmButton : NEO_RscButton
                {
                        idc = 655574;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6848 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_CONFIRM";
                        colorBackground[] = {1,1,1,0.07};
                        sizeEx = CS_BTN_SIZE;
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                };

                //Transport Base Button
                class NEO_radioTransportBaseButton : NEO_radioTransportConfirmButton
                {
                        idc = 655575;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6512 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_RTB";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };

                //Transport Smoke Found Button
                class NEO_radioTransportSmokeFoundButton : NEO_radioTransportConfirmButton
                {
                        idc = 655576;
                        x = 1000 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6176 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_CONFIRM_SMOKE";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };

                //Transport Smoke Found Button same as return to base button
                class NEO_radioTransportSmokeNotFoundButton : NEO_radioTransportBaseButton
                {
                        idc = 655577;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.584 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_NEW_SMOKE";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };

                //Circle Slider
                class NEO_radioTransportCircleSlider : NEO_RscSlider
                {
                        idc = 655578;
                        x = 0.281002 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.5504 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorActive[] = {0.384,0.439,0.341,1};
                        color[] = {0.384,0.439,0.341,1};
                        colorDisabled[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_BTN_SIZE;
                };


                //Circle Slider Text
                class NEO_radioTransportCircleSliderText : NEO_radioTransportHelpUnitText
                {
                        idc = 655579;
                        x = 0.280111 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.514 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "";
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        /*class Attributes
                        {
                                font = "PuristaLight";
                                color = "#FFFFFF";
                                align = "center";
                                valign = "middle";
                                shadow = true;
                                shadowColor = "#000000";
                                size = "1";
                        };*/
                };

                // Slingloading object combo
                class NEO_radioTransportObjectCb : NEO_RscComboBox
                {
                        idc = 655580;
                        x = 0.281002 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.5504 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorSelectBackground[] = {0.384,0.439,0.341,1};
                        colorSelect[] = {0.023529, 0, 0.0313725, 1.000};
                        colorText[] = {0.384,0.439,0.341,1};
                        colorBackground[] = {0.094,0.09,0.094,1};
                        colorScrollbar[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Properties Text
                class NEO_radioTransportPropertiesText : NEO_radioTransportCircleSliderText
                {
                        idc = 655633;
                        text = "$STR_ALIVE_CS_UI_BEHAVIOUR";
                        x = 0.363898 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.598 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                };

                //FlyInHeight CB
                class NEO_radioTransportHeightCb : NEO_RscComboBox
                {
                        idc = 655630;
                        x = 0.278525 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.64 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorSelectBackground[] = {0.384,0.439,0.341,1};
                        colorSelect[] = {0.023529, 0, 0.0313725, 1.000};
                        colorText[] = {0.384,0.439,0.341,1};
                        colorBackground[] = {0.094,0.09,0.094,1};
                        colorScrollbar[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Speed CB
                class NEO_radioTransportSpeedCb : NEO_radioTransportHeightCb
                {
                        idc = 655631;
                        x = 0.401017 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.64 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                };

                //ROE
                class NEO_radioTransportRoeCb : NEO_radioTransportHeightCb
                {
                        idc = 655632;
                        x = 0.339153 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.696 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                };

                //Escort (Eric on Discord, 22 Oct): placed by the transport and ground panels when a unit is picked
                class NEO_radioTransportEscortCb : NEO_radioTransportHeightCb
                {
                        idc = 655638;
                        x = 0.278525 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.752 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                };

                //=======================
                //Cas Unit ListBox
                class NEO_radioCasUnitList : NEO_RscGUIListBox
                {
                        idc = 655582;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3068 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Cas Unit LB Text
                class NEO_radioCasUnitText : NEO_RscText
                {
                        idc = 655583;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0779492 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };

                //Cas Help Unit Text
                class NEO_radioCasHelpUnitText : NEO_radioCasUnitText
                {
                        idc = 655584;
                        x = 0.351527 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.160845 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                        text = "";
                };

                //Cas Confirm Button
                class NEO_radioCasConfirmButton : NEO_radioTransportConfirmButton
                {
                        idc = 655585;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6848 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_CONFIRM";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };

                //Cas Base Button
                class NEO_radioCasBaseButton : NEO_radioCasConfirmButton
                {
                        idc = 655586;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6512 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_RTB";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };
                class NEO_radioSitRepButton : NEO_radioCasConfirmButton
                {
                        idc = 655625;
                        enable = 0; // starts disabled - SITREP no-ops until a unit is selected (enabled in the unit handlers)
                        text = "$STR_ALIVE_CS_UI_SITREP";
                        action = "[] spawn fnc_getSitrep";
                        TABLET_KEY(TABLET_KEY_RX,0); // the painted key R1 (gui_grid.hpp)
                };
                // Terrain toggle - swaps the map between satellite and schematic (see NEO_fnc_radioSetTerrainMode).
                // Sits in the top-right of the tablet frame header (mirroring the ALiVE logo top-left), well
                // clear of the map and every dynamic button, so the map's draw layer never covers it and this
                // same header slot should carry over to the other tablet layouts.
                class NEO_radioTerrainButton : NEO_radioCasConfirmButton
                {
                        idc = 655634;
                        x = 0.676557 * GUI_GRID_WAbs + GUI_GRID_X;   // right edge on the map's right edge
                        y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;   // bottom on the screen's top edge (0.1428)
                        w = 0.0597643 * GUI_GRID_WAbs;
                        h = 0.028 * GUI_GRID_HAbs;
                        text = "$STR_ALIVE_CS_UI_TERRAIN";
                        periodFocus = 1e10; // never blink (periodFocus = 0 can fall back to the default focus-pulse)
                        periodOver = 1e10;
                        period = 1e10; // freeze the base blink too (period 0.4 pulses while the button holds focus)
                        action = "[!(uinamespace getVariable ['NEO_radioTerrainMode', true])] call NEO_fnc_radioSetTerrainMode";
                        colorBackground[] = {0.384,0.439,0.341,1};
                        colorBackgroundFocused[] = {0.384,0.439,0.341,1};
                        colorFocused[] = {0.706,0.706,0.706,1};
                        sizeEx = CS_BTN_SIZE;
                };

                // #630 additive grid-entry - type an 8-digit grid + Set as an alternative to clicking
                // the map. On the header band, left of the Terrain button, clear of the map redraw layer.
                class NEO_radioGridLabel : NEO_RscText
                {
                        idc = 655635;
                        x = 0.510357 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.032 * GUI_GRID_WAbs;
                        h = 0.028 * GUI_GRID_HAbs;
                        text = "$STR_ALIVE_CS_UI_GRID";
                        sizeEx = CS_BTN_SIZE;
                        colorText[] = {1,1,1,1}; // white - the header is dark
                        class Attributes
                        {
                                color = "#FFFFFF";
                        };
                };
                class NEO_radioGridEdit : NEO_RscEdit
                {
                        idc = 655636;
                        x = 0.542357 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1068 * GUI_GRID_HAbs + GUI_GRID_Y; // taller than the buttons, bottoms aligned at 0.1428
                        w = 0.086 * GUI_GRID_WAbs;
                        h = 0.036 * GUI_GRID_HAbs;
                        text = "";
                        sizeEx = 0.034; // larger, comfortably readable
                        colorText[] = {1,1,1,1}; // white on the box's dark grey fill
                        colorBackground[] = {0.173,0.173,0.173,1}; // the lists' fill, so the box shows where to type
                        colorSelection[] = {0.384,0.439,0.341,1};
                        class Attributes
                        {
                                valign = "middle";
                        };
                };
                class NEO_radioGridButton : NEO_radioTerrainButton
                {
                        idc = 655637;
                        x = 0.630557 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.1148 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.043 * GUI_GRID_WAbs;
                        h = 0.028 * GUI_GRID_HAbs;
                        text = "$STR_ALIVE_CS_UI_SET";
                        period = 1e10; // freeze the focus blink (the inherited period 0.4 pulses while the button holds focus)
                        action = "[] call NEO_fnc_radioGridSetButton";
                };

                //CAS Task LB
                class NEO_radioCasTaskList : NEO_radioCasUnitList
                {
                        idc = 655587;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.4272 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Cas Task Text
                class NEO_radioCasTaskText : NEO_radioCasUnitText
                {
                        idc = 655588;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3936 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0742373 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };

                //Cas Task Help Text
                class NEO_radioCasHelpTaskText : NEO_radioCasHelpUnitText
                {
                        idc = 655589;
                        x = 0.351525 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3936 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.160845 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        sizeEx = 0.6 * GUI_GRID_H;
                        text = "";
                };

                //Cas FlyInHeight Slider
                class NEO_radioCasFlyHeightSlider : NEO_radioTransportCircleSlider
                {
                        idc = 655590;
                        x = 0.402708 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.5508 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
            colorActive[] = {0.384,0.439,0.341,1};
                        color[] = {0.384,0.439,0.341,1};
                        colorDisabled[] = {0.384,0.439,0.341,1};
                };

                //Cas FlyInHeight Slider Text
                class NEO_radioCasFlyHeightText : NEO_radioTransportCircleSliderText
                {
                        idc = 655591;
                        x = 0.402708 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.5508 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorActive[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };

                //Cas Radius Slider
                class NEO_radioCasRadiusSlider : NEO_radioTransportCircleSlider
                {
                        idc = 655592;
                        x = 0.281002 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.5504 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorActive[] = {0.384,0.439,0.341,1};
                        color[] = {0.384,0.439,0.341,1};
                        colorDisabled[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_BTN_SIZE;
                };

                //Cas Radius Slider Text
                class NEO_radioCasRadiusText : NEO_radioTransportCircleSliderText
                {
                        idc = 655593;
                        x = 0.280111 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.514 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "";
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                };
                //CAS Attack Run LB
                class NEO_radioCasWeaponList : NEO_radioCasUnitList
                {
                        idc = 655613;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.615 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.125 * GUI_GRID_WAbs;
                        h = 0.12 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Cas Attack Run Text
                class NEO_radioCasWeaponText : NEO_radioCasUnitText
                {
                        idc = 655614;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.59 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.028 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };
                //CAS ROE LB
                class NEO_radioCasROEList : NEO_radioCasUnitList
                {
                        idc = 655615;
                        x = 0.392 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.615 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.125 * GUI_GRID_WAbs;
                        h = 0.12 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };

                //Cas ROE Text
                class NEO_radioCasROEText : NEO_radioCasUnitText
                {
                        idc = 655616;
                        x = 0.402708 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.59 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.028 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };
                class NEO_radioArtyUnitList : NEO_RscGUIListBox
                {
                        idc = 655594;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3068 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };
                class NEO_radioArtyUnitText : NEO_RscText
                {
                        idc = 655595;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0779492 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };
                class NEO_radioArtyHelpUnitText : NEO_radioArtyUnitText
                {
                        idc = 655596;
                        x = 0.351527 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.2732 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.160845 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                        text = "";
                };
                class NEO_radioArtyConfirmButton : NEO_radioTransportConfirmButton
                {
                        idc = 655597;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6848 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_CONFIRM";
                        colorBackground[] = {1,1,1,0.07};
                        colorBackgroundFocused[] = {1,1,1,0.14};
                        colorFocused[] = {1,1,1,0.14};
                        sizeEx = CS_BTN_SIZE;
                };
                class NEO_radioArtyBaseButton : NEO_radioArtyConfirmButton
                {
                        idc = 655610;
                        x = 0.519796 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.6512 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        text = "$STR_ALIVE_CS_UI_RTB";
                        colorBackground[] = {1,1,1,0.07};
                        sizeEx = CS_BTN_SIZE;
                };
                class NEO_radioArtyOrdnanceTypeText : NEO_radioArtyUnitText
                {
                        idc = 655600;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.3936 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0742373 * GUI_GRID_WAbs;
                        h = 0.0308 * GUI_GRID_HAbs;
                        colorText[] = {0.706,0.706,0.706,1};
                        colorBackground[] = {0,0,0,0};
                        colorBackgroundFocused[] = {0,0,0,0};
                        colorFocused[] = {0.706,0.706,0.706,1};
                        sizeEx = CS_BTN_SIZE;
                        text = "";
                };
                class NEO_radioArtyOrdnanceTypeLb : NEO_radioArtyUnitList
                {
                        idc = 655601;
                        x = 0.269865 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.4272 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.242507 * GUI_GRID_WAbs;
                        h = 0.084 * GUI_GRID_HAbs;
                        colorBackground[] = {0,0,0,0};
                        colorActive[] = {0.384,0.439,0.341,1};
                sizeEx = CS_LIST_SIZE;
                        rowHeight = CS_LIST_ROW;
                };
                class NEO_radioArtyRateOfFireText : NEO_radioArtyOrdnanceTypeText
                {
                        idc = 655602;
                        x = 0.271103 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.52 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.080931 * GUI_GRID_WAbs;
                        h = 0.0280024 * GUI_GRID_HAbs;
                };

                //Arty Rate Of Fire Lb
                class NEO_radioArtyRateOfFireLb : NEO_radioArtyOrdnanceTypeLb
                {
                        idc = 655603;
                        x = 0.282108 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.55 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0859113 * GUI_GRID_WAbs;
                        h = 0.0560048 * GUI_GRID_HAbs;
                };

                //Arty Round Count Text
                class NEO_radioArtyRoundCountText : NEO_radioArtyOrdnanceTypeText
                {
                        idc = 655604;
                        x = 0.406618 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.52 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.080931 * GUI_GRID_WAbs;
                        h = 0.0280024 * GUI_GRID_HAbs;
                };

                //Arty Round Count Lb
                class NEO_radioArtyRoundCountLb : NEO_radioArtyOrdnanceTypeLb
                {
                        idc = 655605;
                        x = 0.404129 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.55 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.0859114 * GUI_GRID_WAbs;
                        h = 0.140012 * GUI_GRID_HAbs;
                };
                class NEO_radioArtyMoveButton : NEO_radioTransportSmokeFoundButton
                {
                        idc = 655606;
                        text = "$STR_ALIVE_CS_UI_GET_IN_RANGE";
                        // inherit the parent's visible focused colours - the {0,0,0,0}
                        // overrides blanked the label and fill the moment the cursor
                        // reached the button
                };

                //Arty Dont Move
                class NEO_radioArtyDontMoveButton : NEO_radioTransportSmokeNotFoundButton
                {
                        idc = 655607;
                        text = "$STR_ALIVE_CS_UI_DONT_MOVE";
                        // inherit the parent's visible focused colours (see the move button)
                };
                class NEO_radioArtyDispersionText : NEO_radioCasUnitText
                {
                        idc = 655608;
                        text = "";
                        x = 0.270903 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.68 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.12 * GUI_GRID_WAbs;
                        h = 0.0280024 * GUI_GRID_HAbs;
                };

                //Arty Dispersion Slider
                class NEO_radioArtyDispersionSlider : NEO_radioCasRadiusSlider
                {
                        idc = 655609;
                        x = 0.270903 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.710018 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorActive[] = {0.384,0.439,0.341,1};
                        color[] = {0.384,0.439,0.341,1};
                        colorDisabled[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_BTN_SIZE;
                };
                class NEO_radioArtyRateDelayText : NEO_radioCasUnitText
                {
                        idc = 655611;
                        text = "";
                        x = 0.404129 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.68 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = 0.105833 * GUI_GRID_WAbs;
                        h = 0.0280024 * GUI_GRID_HAbs;
                };

                //Arty Dispersion Slider
                class NEO_radioArtyRateDelaySlider : NEO_radioCasRadiusSlider
                {
                        idc = 655612;
                        x = 0.404129 * GUI_GRID_WAbs + GUI_GRID_X;
                        y = 0.710018 * GUI_GRID_HAbs + GUI_GRID_Y;
                        w = GUI_GRID_WAbs / 1000;
                        h = GUI_GRID_HAbs / 1000;
                        colorText[] = {0.384,0.439,0.341,1};
                        colorActive[] = {0.384,0.439,0.341,1};
                        color[] = {0.384,0.439,0.341,1};
                        colorDisabled[] = {0.384,0.439,0.341,1};
                        sizeEx = CS_BTN_SIZE;
                };

        };
};
