#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(recruitWindow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_recruitWindow

Description:
The recruitment window (#1075): the soldiers and vehicles a Recruitment module offers at
one object, what the selected one is, how full the player's group and vehicle allowance
are, and Recruit (or a double click). Opened by the object's "Recruitment" action.

Parameters:
String - operation: "open" [object, settings], "select", "recruit", "status", "closed"
Any - arguments

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];

#define RW_DISPLAY (findDisplay 9270)

// Lines as structured text: SQF strings have no line-break escape, and parsed markup would
// trip on a display name with < or & in it
private _fnc_lines = {
    params ["_lines", ["_gap", false]];
    private _parts = [];
    { _parts append ([text _x, lineBreak] + ([[], [lineBreak]] select _gap)) } forEach _lines;
    composeText _parts
};
// A class's picture as a file: a soldier's icon is the name of an icon class
private _fnc_picture = {
    params ["_class", "_entry"];
    private _p = getText (configFile >> "CfgVehicles" >> _class >> _entry);
    if (isClass (configFile >> "CfgVehicleIcons" >> _p) || {isText (configFile >> "CfgVehicleIcons" >> _p)}) then { _p = getText (configFile >> "CfgVehicleIcons" >> _p) };
    _p
};

// The list's rows: [class, is a vehicle], then a heading row ["", false, "head"] and the player's
// own recruits [class, is a vehicle, object], which the button dismisses

private _fnc_rows = { uiNamespace getVariable ["ALiVE_recruitRows", []] };

private _fnc_status = {
    private _settings = (uiNamespace getVariable ["ALiVE_recruitAt", []]) param [1, []];
    if (_settings isEqualTo [] || {isNull RW_DISPLAY}) exitWith {};
    _settings params ["", "", "_vehicles", "_max", "", "_maxVeh", "", "", "", "", ["_unitCost", 0], ["_vehicleCost", 0]];
    private _lines = [format [localize "STR_ALIVE_RECRUIT_UI_STATUS_GROUP", { alive _x } count units group player, _max]];
    if ((_vehicles + (_settings param [15, []])) isNotEqualTo []) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_STATUS_VEHICLES", count (call ALiVE_fnc_recruitVehiclesOwned), _maxVeh] };
    // the force pool, once the server has said what is in it (-1: the faction has none)
    private _pool = uiNamespace getVariable ["ALiVE_recruitPool", -1];
    if ((_unitCost > 0 || {_vehicleCost > 0}) && {_pool >= 0}) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_STATUS_POOL", _pool] };
    (RW_DISPLAY displayCtrl 92704) ctrlSetStructuredText ([_lines] call _fnc_lines);
};

switch (_operation) do {

    case "open": {
        _args params [["_object", objNull], ["_settings", []]];
        if (isNull _object || {_settings isEqualTo []} || {!isNull RW_DISPLAY}) exitWith {};
        _settings params ["", "_classes", "_vehicles"];
        createDialog "ALiVE_RecruitWindow";
        uiNamespace setVariable ["ALiVE_recruitAt", [_object, _settings]];
        private _list = RW_DISPLAY displayCtrl 92702;
        private _rows = [];
        {
            private _i = _list lbAdd getText (configFile >> "CfgVehicles" >> _x >> "displayName");
            _list lbSetPicture [_i, [_x, "icon"] call _fnc_picture];
            _rows pushBack [_x, false];
        } forEach _classes;
        {
            private _i = _list lbAdd getText (configFile >> "CfgVehicles" >> _x >> "displayName");
            _list lbSetPicture [_i, [_x, "picture"] call _fnc_picture];
            _list lbSetColor [_i, [0.85, 0.75, 0.55, 1]];
            _rows pushBack [_x, true];
        } forEach _vehicles;
        // the synced men and vehicles, by name; the row's data is the one's place in its list
        {
            private _i = _list lbAdd (_x select 1);
            _list lbSetPicture [_i, [_x select 0, "icon"] call _fnc_picture];
            _list lbSetData [_i, str _forEachIndex];
            _rows pushBack [_x select 0, false];
        } forEach (_settings param [14, []]);
        {
            private _i = _list lbAdd (_x select 1);
            _list lbSetPicture [_i, [_x select 0, "picture"] call _fnc_picture];
            _list lbSetColor [_i, [0.85, 0.75, 0.55, 1]];
            _list lbSetData [_i, str _forEachIndex];
            _rows pushBack [_x select 0, true];
        } forEach (_settings param [15, []]);
        uiNamespace setVariable ["ALiVE_recruitRows", _rows];
        ["mine"] call ALiVE_fnc_recruitWindow;
        _list lbSetCurSel 0;
        uiNamespace setVariable ["ALiVE_recruitPool", -1];
        call _fnc_status;
        // ask the server what is in the force pool when anything here costs
        if ((_settings param [10, 0]) > 0 || {(_settings param [11, 0]) > 0}) then {
            [] spawn { [0] call ALiVE_fnc_recruitAsk; ["status"] call ALiVE_fnc_recruitWindow };
        };
    };

    // the player's recruits that can be dismissed, listed under the offer (#1078)
    case "mine": {
        if (isNull RW_DISPLAY) exitWith {};
        private _settings = (uiNamespace getVariable ["ALiVE_recruitAt", []]) param [1, []];
        private _list = RW_DISPLAY displayCtrl 92702;
        private _rows = (call _fnc_rows) select { count _x < 3 };
        while { lbSize _list > count _rows } do { _list lbDelete (lbSize _list - 1) };
        private _mine = if (_settings param [12, true]) then { call ALiVE_fnc_recruitDismissable } else { [] };
        if (_mine isNotEqualTo []) then {
            private _h = _list lbAdd localize "STR_ALIVE_RECRUIT_UI_YOURS";
            _list lbSetColor [_h, [0.788, 0.443, 0.157, 1]];
            _rows pushBack ["", false, objNull];
            {
                private _i = _list lbAdd format ["   %1", getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")];
                _list lbSetPicture [_i, [typeOf _x, ["icon", "picture"] select !(_x isKindOf "CAManBase")] call _fnc_picture];
                _rows pushBack [typeOf _x, !(_x isKindOf "CAManBase"), _x];
            } forEach _mine;
        };
        uiNamespace setVariable ["ALiVE_recruitRows", _rows];
    };

    case "select": {
        if (isNull RW_DISPLAY) exitWith {};
        private _row = (call _fnc_rows) param [lbCurSel (RW_DISPLAY displayCtrl 92702), []];
        if (_row isEqualTo []) exitWith {};
        // one of the player's own: the button dismisses it
        private _own = count _row > 2;
        (RW_DISPLAY displayCtrl 92705) ctrlSetText localize (["STR_ALIVE_RECRUIT_UI_BUTTON_RECRUIT", "STR_ALIVE_RECRUIT_UI_BUTTON_DISMISS"] select _own);
        (RW_DISPLAY displayCtrl 92705) ctrlEnable (!_own || {!isNull (_row select 2)});
        if (_own) exitWith {
            private _o = _row select 2;
            (RW_DISPLAY displayCtrl 92703) ctrlSetStructuredText ([if (isNull _o) then { [localize "STR_ALIVE_RECRUIT_UI_YOURS_HINT"] } else {
                [getText (configFile >> "CfgVehicles" >> typeOf _o >> "displayName"), format [localize "STR_ALIVE_RECRUIT_UI_YOURS_AWAY", round (player distance _o)]]
            }, true] call _fnc_lines);
        };
        _row params ["_class", "_isVehicle"];
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _settings = (uiNamespace getVariable ["ALiVE_recruitAt", []]) param [1, []];
        // one of the synced men or vehicles: his name and the kit he was placed with
        private _data = (RW_DISPLAY displayCtrl 92702) lbData (lbCurSel (RW_DISPLAY displayCtrl 92702));
        private _template = if (_data != "") then { (_settings param [[14, 15] select _isVehicle, []]) param [parseNumber _data, []] } else { [] };
        private _lines = [_template param [1, getText (_cfg >> "displayName")]];
        if (_isVehicle) then {
            _lines pushBack localize "STR_ALIVE_RECRUIT_UI_DESC_VEHICLE";
            _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_DESC_SEATS", getNumber (_cfg >> "transportSoldier")];
        } else {
            private _weapons = if (_template isEqualTo []) then {
                (getArray (_cfg >> "weapons")) select { !(_x in ["Throw", "Put"]) } apply { getText (configFile >> "CfgWeapons" >> _x >> "displayName") }
            } else {
                // primary, launcher, handgun from the loadout; an empty slot is []
                ((_template param [2, []]) select [0, 3]) apply { _x param [0, ""] } select { _x != "" } apply { getText (configFile >> "CfgWeapons" >> _x >> "displayName") }
            };
            _lines pushBack localize "STR_ALIVE_RECRUIT_UI_DESC_SOLDIER";
            if (_weapons isNotEqualTo []) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_DESC_CARRIES", _weapons joinString ", "] };
        };
        private _cost = _settings param [[10, 11] select _isVehicle, 0];
        if (_cost > 0) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_DESC_COST", _cost] };
        (RW_DISPLAY displayCtrl 92703) ctrlSetStructuredText ([_lines, true] call _fnc_lines);
    };

    case "recruit": {
        if (isNull RW_DISPLAY) exitWith {};
        (uiNamespace getVariable ["ALiVE_recruitAt", []]) params [["_object", objNull], ["_settings", []]];
        private _row = (call _fnc_rows) param [lbCurSel (RW_DISPLAY displayCtrl 92702), []];
        if (isNull _object || {_row isEqualTo []}) exitWith {};
        // one of the player's own: dismiss it, and list what's left
        if (count _row > 2) exitWith {
            if (isNull (_row select 2)) exitWith {};
            private _i = lbCurSel (RW_DISPLAY displayCtrl 92702);
            if ([_row select 2] call ALiVE_fnc_recruitDismiss) then {
                ["mine"] call ALiVE_fnc_recruitWindow;
                (RW_DISPLAY displayCtrl 92702) lbSetCurSel ((_i min (lbSize (RW_DISPLAY displayCtrl 92702) - 1)) max 0);
                [] spawn { sleep 1; ["status"] call ALiVE_fnc_recruitWindow };
            };
        };
        _row params ["_class", "_isVehicle"];
        // one of the synced men or vehicles: recruited as he was placed
        private _data = (RW_DISPLAY displayCtrl 92702) lbData (lbCurSel (RW_DISPLAY displayCtrl 92702));
        private _template = if (_data != "") then { (_settings param [[14, 15] select _isVehicle, []]) param [parseNumber _data, []] } else { [] };
        // paying asks the server and waits for its answer, so this runs scheduled
        [_object, _class, _settings, _isVehicle, _template] spawn {
            params ["_object", "_class", "_settings", "_isVehicle", "_template"];
            if (_isVehicle) then { [_object, _class, _settings, _template] call ALiVE_fnc_recruitVehicle } else { [_object, _class, _settings, _template] call ALiVE_fnc_recruitUnit };
            ["status"] call ALiVE_fnc_recruitWindow;
            private _i = lbCurSel (RW_DISPLAY displayCtrl 92702);
            ["mine"] call ALiVE_fnc_recruitWindow;
            (RW_DISPLAY displayCtrl 92702) lbSetCurSel _i;
        };
    };

    case "status": {
        call _fnc_status;
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_recruitAt", []];
        uiNamespace setVariable ["ALiVE_recruitRows", []];
    };
};
