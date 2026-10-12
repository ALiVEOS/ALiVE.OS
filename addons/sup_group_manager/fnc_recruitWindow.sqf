#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(recruitWindow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_recruitWindow

Description:
The recruitment window (#1075): the soldiers and vehicles a Recruitment module offers at
one object, what the selected one is, how full the player's group and vehicle allowance
are, and Recruit (or a double click). Opened by the object's "Recruitment" action.

Parameters:
String - operation: "open" [object, settings], "select", "recruit", "closed"
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

// The list's rows: [class, is a vehicle]
private _fnc_rows = { uiNamespace getVariable ["ALiVE_recruitRows", []] };

private _fnc_status = {
    private _settings = (uiNamespace getVariable ["ALiVE_recruitAt", []]) param [1, []];
    if (_settings isEqualTo [] || {isNull RW_DISPLAY}) exitWith {};
    _settings params ["", "", "_vehicles", "_max", "", "_maxVeh"];
    private _lines = [format [localize "STR_ALIVE_RECRUIT_UI_STATUS_GROUP", { alive _x } count units group player, _max]];
    if (_vehicles isNotEqualTo []) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_STATUS_VEHICLES", count (call ALiVE_fnc_recruitVehiclesOwned), _maxVeh] };
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
        uiNamespace setVariable ["ALiVE_recruitRows", _rows];
        _list lbSetCurSel 0;
        call _fnc_status;
    };

    case "select": {
        if (isNull RW_DISPLAY) exitWith {};
        private _row = (call _fnc_rows) param [lbCurSel (RW_DISPLAY displayCtrl 92702), []];
        if (_row isEqualTo []) exitWith {};
        _row params ["_class", "_isVehicle"];
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _lines = [getText (_cfg >> "displayName")];
        if (_isVehicle) then {
            _lines pushBack localize "STR_ALIVE_RECRUIT_UI_DESC_VEHICLE";
            _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_DESC_SEATS", getNumber (_cfg >> "transportSoldier")];
        } else {
            private _weapons = (getArray (_cfg >> "weapons")) select { !(_x in ["Throw", "Put"]) } apply { getText (configFile >> "CfgWeapons" >> _x >> "displayName") };
            _lines pushBack localize "STR_ALIVE_RECRUIT_UI_DESC_SOLDIER";
            if (_weapons isNotEqualTo []) then { _lines pushBack format [localize "STR_ALIVE_RECRUIT_UI_DESC_CARRIES", _weapons joinString ", "] };
        };
        (RW_DISPLAY displayCtrl 92703) ctrlSetStructuredText ([_lines, true] call _fnc_lines);
    };

    case "recruit": {
        if (isNull RW_DISPLAY) exitWith {};
        (uiNamespace getVariable ["ALiVE_recruitAt", []]) params [["_object", objNull], ["_settings", []]];
        private _row = (call _fnc_rows) param [lbCurSel (RW_DISPLAY displayCtrl 92702), []];
        if (isNull _object || {_row isEqualTo []}) exitWith {};
        _row params ["_class", "_isVehicle"];
        if (_isVehicle) then { [_object, _class, _settings] call ALiVE_fnc_recruitVehicle } else { [_object, _class, _settings] call ALiVE_fnc_recruitUnit };
        call _fnc_status;
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_recruitAt", []];
        uiNamespace setVariable ["ALiVE_recruitRows", []];
    };
};
