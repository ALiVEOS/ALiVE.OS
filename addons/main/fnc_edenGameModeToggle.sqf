#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenGameModeToggle);

/* ----------------------------------------------------------------------------
Function: fnc_edenGameModeToggle

Description:
ALiVE (Required) in Eden: Zombie Side shows only while Game Mode is Outbreak. Called from the two
settings' attributeLoad (ALiVE_GameModeCombo, ALiVE_ZombieSideCombo) after Eden's own combo has
filled them, and again whenever Game Mode changes. The row is marked alive_rowOff and the section
layout (fnc_edenSectionCollapse.sqf) hides it and closes up the gap; the setting keeps its value.

Modes:
    "gamemode"   [CONTROL]  - the Game Mode setting has loaded
    "zombieside" [CONTROL]  - the Zombie Side setting has loaded
    "apply"      [CONTROL]  - either setting: show or hide Zombie Side for the current Game Mode

Author:
Jman
---------------------------------------------------------------------------- */

#define SELF '\x\alive\addons\main\fnc_edenGameModeToggle.sqf'

params ["_mode", ["_row", controlNull]];
if (isNull _row) exitWith {};
private _display = ctrlParent _row;

switch (_mode) do {
    case "gamemode": {
        _display setVariable ["alive_gameModeRow", _row];
        (_row controlsGroupCtrl 100) ctrlAddEventHandler ["LBSelChanged", {
            ["apply", ctrlParentControlsGroup (_this select 0)] call compile preprocessFileLineNumbers SELF;
        }];
        ["apply", _row] call compile preprocessFileLineNumbers SELF;
    };

    case "zombieside": {
        _display setVariable ["alive_zombieSideRow", _row];
        ["apply", _row] call compile preprocessFileLineNumbers SELF;
    };

    case "apply": {
        private _gameMode = _display getVariable ["alive_gameModeRow", controlNull];
        private _zombieSide = _display getVariable ["alive_zombieSideRow", controlNull];
        if (isNull _gameMode || {isNull _zombieSide}) exitWith {};
        private _combo = _gameMode controlsGroupCtrl 100;
        private _outbreak = toLower (_combo lbData (lbCurSel _combo)) == "outbreak";
        if ((_zombieSide getVariable ["alive_rowOff", false]) isEqualTo !_outbreak && {_zombieSide getVariable ["alive_rowOffSet", false]}) exitWith {};
        _zombieSide setVariable ["alive_rowOff", !_outbreak];
        _zombieSide setVariable ["alive_rowOffSet", true];
        ["queue", _display] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenSectionCollapse.sqf';
    };
};
