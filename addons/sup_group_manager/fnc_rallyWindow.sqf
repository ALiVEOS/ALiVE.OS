#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(rallyWindow);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_rallyWindow

Description:
The Rally Points window: the other rally points the player may use, with how far and which
way each is, and Travel.

Parameters:
_this select 0: STRING - "open", "select", "travel" or "closed"; "rename" and "renameSend" for
the Rename Rally Point window

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]]];

private _d = findDisplay 9284;

switch (_op) do {
    case "open": {
        private _here = missionNamespace getVariable ["ALiVE_rallyNear", []];
        if (_here isEqualTo []) exitWith {};
        private _rows = (["list", [player]] call ALiVE_fnc_rallyPoint) select { ((_x select 1) distance (_here select 1)) > 20 };
        if (_rows isEqualTo []) exitWith { [localize "STR_ALIVE_RALLY", localize "STR_ALIVE_RALLY_UI_NONE"] call ALIVE_fnc_sendHint };
        _rows = [_rows, [], { (_x select 1) distance (_here select 1) }, "ASCEND"] call BIS_fnc_sortBy;
        uiNamespace setVariable ["ALiVE_rallyRows", _rows];
        uiNamespace setVariable ["ALiVE_rallyMapShown", nil];
        createDialog "ALiVE_RallyWindow";
        _d = findDisplay 9284;
        (_d displayCtrl 92801) ctrlSetText format [localize "STR_ALIVE_RALLY_UI_TITLE", _here select 0];
        private _list = _d displayCtrl 92802;
        {
            private _dist = (getPosASL player) distance2D (_x select 1);
            private _dir = (getPosASL player) getDir (_x select 1);
            private _compass = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"] select (round (_dir / 45) mod 8);
            _list lbAdd format ["%1  (%2 %3)", _x select 0, if (_dist >= 1000) then { format ["%1 km", (_dist / 1000) toFixed 1] } else { format ["%1 m", round _dist] }, _compass];
        } forEach _rows;
        _list lbSetCurSel 0;
    };
    case "select": {
        private _rows = uiNamespace getVariable ["ALiVE_rallyRows", []];
        private _i = lbCurSel (_d displayCtrl 92802);
        if (_i < 0 || {_i >= count _rows}) exitWith {};
        private _row = _rows select _i;
        private _who = if (leader group player == player) then {
            private _r = (ALiVE_rallyLogic getVariable ["squadRadius", 150]);
            if (_r isEqualType "") then { _r = parseNumber _r };
            count ((units group player) select { !isPlayer _x && {alive _x} && {vehicle _x == _x} && {(_x distance player) < _r} && {lifeState _x in ["HEALTHY", "INJURED"]} })
        } else { 0 };
        (_d displayCtrl 92803) ctrlSetStructuredText parseText format [localize "STR_ALIVE_RALLY_UI_DETAILS", _row select 0, mapGridPosition ASLToAGL (_row select 1), _who];
        // the map moves to the picked rally point; the first one opens there without the pan
        private _map = _d displayCtrl 92807;
        if (!isNull _map) then {
            _map ctrlMapAnimAdd [[0.5, 0] select (isNil {uiNamespace getVariable "ALiVE_rallyMapShown"}), 0.08, ASLToAGL (_row select 1)];
            ctrlMapAnimCommit _map;
            uiNamespace setVariable ["ALiVE_rallyMapShown", true];
        };
    };
    case "travel": {
        private _rows = uiNamespace getVariable ["ALiVE_rallyRows", []];
        private _i = lbCurSel (_d displayCtrl 92802);
        if (_i < 0 || {_i >= count _rows}) exitWith {};
        private _row = _rows select _i;
        closeDialog 0;
        ["travel", [player, _row, false]] call ALiVE_fnc_rallyPoint;
    };
    case "closed": {
        uiNamespace setVariable ["ALiVE_rallyRows", nil];
    };
    // Rename Rally Point: the rename window with the squad's rally point's name in it
    case "rename": {
        private _obj = group player getVariable ["ALiVE_rallyDeployed", objNull];
        if (isNull _obj || {!createDialog "ALiVE_RallyRenameWindow"}) exitWith {};
        private _row = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { (_x select 0) == _obj };
        private _r = findDisplay 9282;
        (_r displayCtrl 92831) ctrlSetText ((_row param [0, []]) param [1, ""]);
        ctrlSetFocus (_r displayCtrl 92831);
    };
    case "renameSend": {
        private _r = findDisplay 9282;
        if (isNull _r) exitWith {};
        ["rename", [player, ctrlText (_r displayCtrl 92831)]] call ALiVE_fnc_rallyPoint;
        closeDialog 1;
    };
};
