// The ORBAT Creator from the main menu: a tile in the menu's spotlight row and an ALiVE menu on the top bar after
// OPTIONS, both starting the studio scene (scene\ALiVE_FactionStudio.VR). The menu also links to the ALiVE web tools.
// Showcases lists the studio too (CfgMissions.hpp), as a way in if another mod reshapes the main menu.
// Author: Jman

class CfgMainMenuSpotlight {
    class ALiVE_ORBATCreator {
        text = "$STR_ALIVE_FS_NAME";
        textIsQuote = 0;
        picture = "\x\alive\addons\sys_orbatcreator\data\images\fs_spotlight_co.paa";
        video = "";
        action = "playMission ['', '\x\alive\addons\sys_orbatcreator\scene\ALiVE_FactionStudio.VR', true]";
        actionText = "$STR_ALIVE_FS_MAINMENU_OPEN";
        condition = "true";
    };
};

class RscStandardDisplay;
class RscButtonMenuMain;

// one row of the ALiVE menu, sized as the rows of the game's own menus
class ALiVE_ORBATMenuItem : RscButtonMenuMain {
    x = 0;
    w = "10 * (pixelW * pixelGrid * 2)";
    h = "1.5 * (pixelH * pixelGrid * 2) - pixelH";
};

class RscDisplayMain : RscStandardDisplay {
    class controls {
        class TitleSingleplayer;
        // The next slot along the top bar after OPTIONS, in the same style as the game's own titles. The bar's width
        // in grid units shrinks as the UI size grows: when the title would reach the profile icon it narrows to its
        // text, and when even that won't fit it sits above the info rows, left of the news panel (data\ui\mainMenu.sqf).
        class ALiVE_ORBATCreatorButton : TitleSingleplayer {
            idc = 14099;
            text = "$STR_ALIVE_FS_MAINMENU_ALIVE";
            tooltip = "$STR_ALIVE_FS_MAINMENU_ALIVE_TIP";
            x = "0.5 + (5 + 2 * 10) * (pixelW * pixelGrid * 2)";
            onLoad = "uiNamespace setVariable ['ALiVE_FS_mainMenu', compile preprocessFileLineNumbers '\x\alive\addons\sys_orbatcreator\data\ui\mainMenu.sqf']; ['load', _this] call (uiNamespace getVariable 'ALiVE_FS_mainMenu');";
            onMouseEnter = "['open', _this] call (uiNamespace getVariable 'ALiVE_FS_mainMenu');";
            onSetFocus = "['open', _this] call (uiNamespace getVariable 'ALiVE_FS_mainMenu');";
        };
        // folded until the title opens it
        class ALiVE_ORBATCreatorMenu : RscControlsGroupNoScrollbars {
            idc = 14098;
            x = "0.5 + (5 + 2 * 10) * (pixelW * pixelGrid * 2)";
            y = "safezoneY + (2 + 2) * (pixelH * pixelGrid * 2)";
            w = "10 * (pixelW * pixelGrid * 2)";
            h = 0;
            class Controls {
                class OrbatCreator : ALiVE_ORBATMenuItem {
                    idc = 14093;
                    text = "$STR_ALIVE_FS_NAME";
                    tooltip = "$STR_ALIVE_FS_MAINMENU_TIP";
                    y = "(0 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    onButtonClick = "playMission ['', '\x\alive\addons\sys_orbatcreator\scene\ALiVE_FactionStudio.VR', true]";
                };
                class WarRoom : ALiVE_ORBATMenuItem {
                    idc = 14094;
                    text = "$STR_ALIVE_FS_MAINMENU_WARROOM";
                    tooltip = "$STR_ALIVE_FS_MAINMENU_WARROOM_TIP";
                    y = "(1 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    url = "https://www.alivemod.com/warroom/";
                };
                class MissionBuilder : ALiVE_ORBATMenuItem {
                    idc = 14095;
                    text = "$STR_ALIVE_FS_MAINMENU_BUILDER";
                    tooltip = "$STR_ALIVE_FS_MAINMENU_BUILDER_TIP";
                    y = "(2 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    url = "https://www.alivemod.com/alive3/mission_builder.htm";
                };
                class TerrainIndexer : ALiVE_ORBATMenuItem {
                    idc = 14096;
                    text = "$STR_ALIVE_FS_MAINMENU_TERRAIN";
                    tooltip = "$STR_ALIVE_FS_MAINMENU_TERRAIN_TIP";
                    y = "(3 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    url = "https://www.alivemod.com/alive3/index_terrain.htm";
                };
                class ServerBrowser : ALiVE_ORBATMenuItem {
                    idc = 14097;
                    text = "$STR_ALIVE_FS_MAINMENU_SERVERS";
                    tooltip = "$STR_ALIVE_FS_MAINMENU_SERVERS_TIP";
                    y = "(4 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    url = "https://www.alivemod.com/warroom/#browser";
                };
            };
        };
    };
};
