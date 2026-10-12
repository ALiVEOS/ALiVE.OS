#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(buildMenu);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_buildMenu

Description:
The FOB build window on the player's machine (idd 9280). It lists the build catalog the server
sent (fortifications or supply, cheapest first), shows the selected item's picture and price
and the FOB's supply, and Place closes the window and starts placing the item in the world
(ALiVE_fnc_fobPlacement). Prices shown here are the server's; the server charges its own.

Parameters:
String - The operation: open, category, select, place, closed
Any - Its arguments: for open, the FOB's row from ALiVE_FOB_registryMirror; for category,
"FORTIFICATION" or "SUPPLY"

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

params [["_operation", "", [""]], ["_args", []]];

#define BW_DISPLAY (findDisplay 9280)

// Plain lines as structured text, so a name with < or & in it shows as written
private _fnc_lines = {
    params ["_lines", ["_gap", false]];
    private _parts = [];
    { _parts append ([text _x, lineBreak] + ([[], [lineBreak]] select _gap)) } forEach _lines;
    composeText _parts
};

// The FOB the window is for, as the latest copy from the server has it
private _fnc_fob = {
    private _id = uiNamespace getVariable ["ALiVE_FOB_buildAt", ""];
    private _rows = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 0) == _id };
    _rows param [0, []]
};

private _fnc_status = {
    if (isNull BW_DISPLAY) exitWith {};
    private _fob = call _fnc_fob;
    if (_fob isEqualTo []) exitWith {};
    _fob params ["", "", "_name", "", "", "_tier", "_supply", "_cap"];
    private _s = if (_supply < 0) then { localize "STR_ALIVE_FOB_SUPPLY_FREE" } else { format ["%1 / %2", round _supply, round _cap] };
    (BW_DISPLAY displayCtrl 92804) ctrlSetStructuredText ([[_name, format [localize "STR_ALIVE_FOB_UI_SUPPLY_LINE", _s]]] call _fnc_lines);
};

switch (_operation) do {

    case "open": {
        if (!isNull BW_DISPLAY || {_args isEqualTo []}) exitWith {};
        if ((missionNamespace getVariable ["ALiVE_FOB_catalog", []]) isEqualTo []) exitWith {
            [localize "STR_ALIVE_FOB", localize "STR_ALIVE_FOB_UI_NO_CATALOG"] call ALIVE_fnc_sendHint;
        };
        uiNamespace setVariable ["ALiVE_FOB_buildAt", _args select 0];
        createDialog "ALiVE_FobBuildWindow";
        ["category", uiNamespace getVariable ["ALiVE_FOB_buildCategory", "FORTIFICATION"]] call ALiVE_fnc_buildMenu;
    };

    case "category": {
        if (isNull BW_DISPLAY) exitWith {};
        private _kind = _args;
        uiNamespace setVariable ["ALiVE_FOB_buildCategory", _kind];
        private _rows = (missionNamespace getVariable ["ALiVE_FOB_catalog", []]) select { (_x select 2) == _kind };
        // cheapest first, then by name
        private _keys = [];
        { _keys pushBack [_x select 3, _x select 1, _forEachIndex] } forEach _rows;
        _keys sort true;
        _rows = _keys apply { _rows select (_x select 2) };
        uiNamespace setVariable ["ALiVE_FOB_buildRows", _rows];
        private _list = BW_DISPLAY displayCtrl 92802;
        lbClear _list;
        {
            _x params ["_class", "_name", "", "_cost"];
            private _i = _list lbAdd format ["%1  (%2)", [_name, _class] select (_name == ""), _cost];
            private _icon = getText (configFile >> "CfgVehicles" >> _class >> "icon");
            if (isText (configFile >> "CfgVehicleIcons" >> _icon)) then { _icon = getText (configFile >> "CfgVehicleIcons" >> _icon) };
            if (_icon != "" && {"\" in _icon}) then { _list lbSetPicture [_i, _icon] };
        } forEach _rows;
        {
            (BW_DISPLAY displayCtrl (_x select 0)) ctrlSetTextColor ([[1,1,1,0.6], [1,1,1,1]] select (_kind == (_x select 1)));
        } forEach [[92807, "FORTIFICATION"], [92808, "SUPPLY"]];
        _list lbSetCurSel 0;
        call _fnc_status;
    };

    case "select": {
        if (isNull BW_DISPLAY) exitWith {};
        private _row = (uiNamespace getVariable ["ALiVE_FOB_buildRows", []]) param [lbCurSel (BW_DISPLAY displayCtrl 92802), []];
        if (_row isEqualTo []) exitWith {};
        _row params ["_class", "_name", "_kind", "_cost", "_pic"];
        (BW_DISPLAY displayCtrl 92809) ctrlSetText _pic;
        private _lines = [[_name, _class] select (_name == ""), localize (["STR_ALIVE_FOB_UI_FORTIFICATION", "STR_ALIVE_FOB_UI_SUPPLY_ITEM"] select (_kind == "SUPPLY")), format [localize "STR_ALIVE_FOB_UI_COST", _cost]];
        (BW_DISPLAY displayCtrl 92803) ctrlSetStructuredText ([_lines, true] call _fnc_lines);
        call _fnc_status;
    };

    case "place": {
        if (isNull BW_DISPLAY) exitWith {};
        private _row = (uiNamespace getVariable ["ALiVE_FOB_buildRows", []]) param [lbCurSel (BW_DISPLAY displayCtrl 92802), []];
        private _fob = call _fnc_fob;
        if (_row isEqualTo [] || {_fob isEqualTo []}) exitWith {};
        closeDialog 0;
        ["start", [_row, _fob]] call ALiVE_fnc_fobPlacement;
    };

    case "status": {
        call _fnc_status;
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_FOB_buildRows", []];
    };
};
