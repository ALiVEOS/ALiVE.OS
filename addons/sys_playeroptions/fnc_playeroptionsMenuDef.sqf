#include "\x\alive\addons\sys_playeroptions\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(playeroptionsMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playeroptionsMenuDef
Description:
This function controls the View portion of player options.

Parameters:
Object - The object to attach the menu too
Array - The menu parameters

Returns:
Array - Returns the menu definitions for FlexiMenu

Examples:
(begin example)
// initialise main menu
[
    "player",
    [221,[false,false,false]],
    -9500,
    ["call ALIVE_fnc_playeroptionsMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_adminActions>
- <CBA_fnc_flexiMenu_Add>

Author:
Tupolov
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_menuDef", "_target", "_params", "_menuName", "_menuRsc", "_menus"];
// _this==[_target, _menuNameOrParams]

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";

if (typeName _params == typeName []) then {
    if (count _params < 1) exitWith {["Error: Invalid params: %1, %2", _this, __FILE__] call ALiVE_fnc_dump;};
    _menuName = _params select 0;
    _menuRsc = if (count _params > 1) then {_params select 1} else {_menuRsc};
} else {
    _menuName = _params;
};
//-----------------------------------------------------------------------------
/*
        ["Menu Caption", "flexiMenu resource dialog", "optional icon folder", menuStayOpenUponSelect],
        [
            ["caption",
                "action",
                "icon",
                "tooltip",
                {"submenu"|["menuName", "", {0|1} (optional - use embedded list menu)]},
                -1 (shortcut DIK code),
                {0|1/"0"|"1"/false|true} (enabled),
                {-1|0|1/"-1"|"0"|"1"/false|true} (visible)
            ],
             ...
*/
_menus =
[
    [
        ["main", "ALiVE", _menuRsc],
        [
            [localize "STR_ALIVE_PLAYEROPTIONS_SHORT" + " >",
                "",
                "",
                localize "STR_ALIVE_PLAYEROPTIONS_COMMENT",
                ["call ALiVE_fnc_playeroptionsMenuDef", "playeroptions", 1],
                -1,
                1,
                !isnil QMOD(sys_playeroptions)
            ]
        ]
    ]
];


if (_menuName == "playeroptions") then {
    _menus set [count _menus,
        [
            ["playeroptions", localize "STR_ALIVE_PLAYEROPTIONS", "popup"],
            [
                [localize "STR_ALIVE_VDIST",
                    {[] call ALIVE_fnc_vDistGuiInit},
                    "",
                    localize "STR_ALIVE_VDIST_COMMENT",
                     "",
                     -1,
                     1,
                     true
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE" + " >",
                    "",
                    "",
                    localize "STR_ALIVE_PLAYEROPTIONS_ACE_COMMENT",
                    ["call ALiVE_fnc_playeroptionsMenuDef", "aceoptions", 1],
                    -1,
                    true,
                    ["available"] call ALiVE_fnc_playeroptionsAce
                ],
                [localize "STR_ALIVE_PLAYERTAGS_DISPLAY_ENABLE",
                    { MOD(sys_playertags) setVariable ["display_enabled", true]; true call MOD(sys_playertags_TRIGGER); },
                    "",
                    localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
                    "",
                    -1,
                     true,
                    !isnil QMOD(sys_playertags) && {!(MOD(sys_playertags) getVariable ["display_enabled", false])} && {!isNil QMOD(sys_playertags_TRIGGER)}
                ],
                [localize "STR_ALIVE_PLAYERTAGS_DISPLAY_DISABLE",
                     {     MOD(sys_playertags)  setVariable ["display_enabled", false]; false call MOD(sys_playertags_TRIGGER); },
                    "",
                    localize "STR_ALIVE_PLAYERTAGS_DISPLAY_COMMENT",
                    "",
                    -1,
                      true,
                    !isnil QMOD(sys_playertags) && {MOD(sys_playertags) getVariable ["display_enabled", false]} && {!isNil QMOD(sys_playertags_TRIGGER)}
                ],
                [localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS",
                    "[ALiVE_SYS_LOGISTICS, ""addActions""] call ALiVE_fnc_Logistics",
                    "",
                    localize "STR_ALIVE_LOGISTICS_ENABLEACTIONS_COMMENT",
                    "",
                    -1,
                    true,
                    !isnil QMOD(sys_logistics) && (isnil {player getvariable [QMOD(SYS_LOGISTICS_ACTIONS),nil]}) && {!(MOD(sys_logistics) getVariable ["DISABLELOG", false])}
                ],
                [localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS",
                    "[ALiVE_SYS_LOGISTICS, ""removeActions""] call ALiVE_fnc_Logistics",
                    "",
                    localize "STR_ALIVE_LOGISTICS_DISABLEACTIONS_COMMENT",
                    "",
                    -1,
                    true,
                    !isnil QMOD(sys_logistics) && !(isnil {player getvariable [QMOD(SYS_LOGISTICS_ACTIONS),nil]}) && {!(MOD(sys_logistics) getVariable ["DISABLELOG", false])}
                ],
                [localize "STR_ALIVE_player_allowReset_ACTION",
                    { [MOD(sys_player), "resetPlayer", [player]] call ALIVE_fnc_player;},
                    "",
                    localize "STR_ALIVE_player_allowReset_ACTION_COMMENT",
                    "",
                    -1,
                    !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["allowReset", false]},
                    !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["enablePlayerPersistence",false]} && {MOD(sys_player) getVariable ["allowReset", false]}
                ],
                [localize "STR_ALIVE_player_allowManualSave_ACTION",
                    { [MOD(sys_player), "manualSavePlayer", [player]] call ALIVE_fnc_player },
                    "",
                    localize "STR_ALIVE_player_allowManualSave_ACTION_COMMENT",
                    "",
                    -1,
                     !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["allowManualSave", true]},
                     !isNil QMOD(sys_player) && {MOD(sys_player) getVariable ["enablePlayerPersistence",false]} && {MOD(sys_player) getVariable ["allowManualSave", true]}
                ],
                [localize "STR_ALIVE_player_RESTORE_MARKERS",
                    {[ALIVE_SYS_MARKER, "restoreMarkers", [ALIVE_SYS_MARKER_STORE]] call ALiVE_fnc_marker},
                    "",
                    localize "STR_ALIVE_player_RESTORE_MARKERS_COMMENT",
                     "",
                     -1,
                     true,
                     !(MOD(require) getVariable["ALiVE_DISABLEMARKERS",false])
                ]
            ]
        ]
    ];
};

// The player's own fatigue and weapon sway (ALiVE_fnc_playeroptionsAce): ACE's when they are running,
// the game's stamina and sway otherwise. An item whose value the server or mission chose stays listed
// but disabled.
if (_menuName == "aceoptions") then {
    private _fatigueShown = ["fatigueOn"] call ALiVE_fnc_playeroptionsAce;
    private _fatigueFree = !(["forced", "ace_advanced_fatigue_performanceFactor"] call ALiVE_fnc_playeroptionsAce);
    private _light = missionNamespace getVariable ["ALiVE_playerOptions_aceFatigue", false];
    private _aceSway = ["swayOn"] call ALiVE_fnc_playeroptionsAce;
    private _swayShown = true;
    private _swayFree = !_aceSway || {!(["forced", "ace_common_swayFactor"] call ALiVE_fnc_playeroptionsAce)};
    private _sway = if (_aceSway) then { ["swayValue"] call ALiVE_fnc_playeroptionsAce } else { missionNamespace getVariable ["ALiVE_playerOptions_aceSway", 1] };
    private _staminaOff = missionNamespace getVariable ["ALiVE_playerOptions_staminaOff", false];
    private _fatigueTip = [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FORCED", localize "STR_ALIVE_PLAYEROPTIONS_ACE_FATIGUE_COMMENT"] select _fatigueFree;
    private _swayTip = [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FORCED", localize "STR_ALIVE_PLAYEROPTIONS_ACE_SWAY_COMMENT"] select _swayFree;
    _menus set [count _menus,
        [
            ["aceoptions", localize "STR_ALIVE_PLAYEROPTIONS_ACE", "popup"],
            [
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FATIGUE_LIGHT",
                    { ["fatigue", true] call ALiVE_fnc_playeroptionsAce },
                    "", _fatigueTip, "", -1,
                    _fatigueFree,
                    _fatigueShown && {!_light}
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FATIGUE_NORMAL",
                    { ["fatigue", false] call ALiVE_fnc_playeroptionsAce },
                    "", _fatigueTip, "", -1,
                    true,
                    _fatigueShown && {_light}
                ],
                // the game's stamina: only the player's own "off" is undone, so stamina a mission
                // turned off itself stays off
                [localize "STR_ALIVE_PLAYEROPTIONS_STAMINA_OFF",
                    { ["stamina", true] call ALiVE_fnc_playeroptionsAce },
                    "", localize "STR_ALIVE_PLAYEROPTIONS_STAMINA_COMMENT", "", -1,
                    true,
                    !_fatigueShown && {!_staminaOff} && {isStaminaEnabled player}
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_STAMINA_NORMAL",
                    { ["stamina", false] call ALiVE_fnc_playeroptionsAce },
                    "", localize "STR_ALIVE_PLAYEROPTIONS_STAMINA_COMMENT", "", -1,
                    true,
                    !_fatigueShown && {_staminaOff}
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE_SWAY_NORMAL",
                    { ["sway", 1] call ALiVE_fnc_playeroptionsAce },
                    "", _swayTip, "", -1,
                    true,
                    _swayShown && {_sway != 1}
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE_SWAY_REDUCED",
                    { ["sway", 0.5] call ALiVE_fnc_playeroptionsAce },
                    "", _swayTip, "", -1,
                    _swayFree,
                    _swayShown && {_sway != 0.5}
                ],
                [localize "STR_ALIVE_PLAYEROPTIONS_ACE_SWAY_OFF",
                    { ["sway", 0] call ALiVE_fnc_playeroptionsAce },
                    "", _swayTip, "", -1,
                    _swayFree,
                    _swayShown && {_sway != 0}
                ]
            ]
        ]
    ];
};

//-----------------------------------------------------------------------------
// Normalize CBA flexiMenu code-block actions to the string form required by
// buttonSetAction (CBA fnc_list.sqf / fnc_menu.sqf passes the action slot
// straight through, which strictly needs STRING).
_menus call ALiVE_fnc_normalizeFlexiMenuActions;

_menuDef = [];
{
    if (_x select 0 select 0 == _menuName) exitWith {_menuDef = _x};
} forEach _menus;

if (count _menuDef == 0) then {
    hintC format ["Error: Menu not found: %1\n%2\n%3", str _menuName, if (_menuName == "") then {_this}else{""}, __FILE__];
    ["Error: Menu not found: %1, %2, %3", str _menuName, _this, __FILE__] call ALiVE_fnc_dump;
};

_menuDef // return value
