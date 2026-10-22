#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(buildMenu);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_buildMenu

Description:
The FOB build window on the player's machine (idd 9280). It lists the build catalog the server
sent (fortifications, supply, or the player's side's static weapons, cheapest first), shows the selected item's picture and price
and the FOB's supply, and Place closes the window and starts placing the item in the world
(ALiVE_fnc_fobPlacement). Prices shown here are the server's; the server charges its own.

Parameters:
String - The operation: open, category, filter, select, place, closed
Any - Its arguments: for open, the FOB's row from ALiVE_FOB_registryMirror; for category,
"FORTIFICATION", "SUPPLY" or "STATIC"

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
    private _s = if (_supply < 0) then { localize "STR_ALIVE_FOB_SUPPLY_FREE" } else { if (_cap < 0) then { format [localize "STR_ALIVE_FOB_SUPPLY_POOL", round _supply] } else { format ["%1 / %2", round _supply, round _cap] } };
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
        // the tier filter, starting on what this FOB can build now; filled before the category
        // so the first list is already filtered
        private _tier = BW_DISPLAY displayCtrl 92814;
        {
            _tier lbSetValue [_tier lbAdd (_x select 0), _x select 1];
        } forEach [[localize "STR_ALIVE_FOB_UI_TIER_AVAILABLE", 0], [format [localize "STR_ALIVE_FOB_UI_TIER_N", 1], 1],
            [format [localize "STR_ALIVE_FOB_UI_TIER_N", 2], 2], [format [localize "STR_ALIVE_FOB_UI_TIER_N", 3], 3], [localize "STR_ALIVE_FOB_UI_TIER_ALL", 9]];
        uiNamespace setVariable ["ALiVE_FOB_buildFilling", true];
        _tier lbSetCurSel 0;
        uiNamespace setVariable ["ALiVE_FOB_buildFilling", false];
        ["category", uiNamespace getVariable ["ALiVE_FOB_buildCategory", "FORTIFICATION"]] call ALiVE_fnc_buildMenu;
    };

    case "category": {
        if (isNull BW_DISPLAY) exitWith {};
        private _kind = _args;
        uiNamespace setVariable ["ALiVE_FOB_buildCategory", _kind];
        // static weapons and vehicles from the factions the side's commanders field (its own side's
        // when it has none)
        private _side = str (side group player);
        private _allowed = ((missionNamespace getVariable ["ALiVE_FOB_sideFactions", []]) select { (_x select 0) == _side }) param [0, ["", []]] select 1;
        // and only what this FOB's type may build (FOB Types)
        private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
        private _type = (call _fnc_fob) param [10, ""];
        private _rows = (missionNamespace getVariable ["ALiVE_FOB_catalog", []]) select {
            (_x select 2) == _kind && {!(_kind in ["STATIC", "VEHICLE"])
                || {[(_x param [6, ""]) == _side, (_x param [7, ""]) in _allowed] select (_allowed isNotEqualTo [])}}
                && {[_logic, "typeAllows", [_type, _x select 0]] call ALiVE_fnc_FOB}
        };
        // cheapest first, then by name
        private _keys = [];
        { _keys pushBack [_x select 3, _x select 1, _forEachIndex] } forEach _rows;
        _keys sort true;
        _rows = _keys apply { _rows select (_x select 2) };
        uiNamespace setVariable ["ALiVE_FOB_buildAll", _rows];
        {
            (BW_DISPLAY displayCtrl (_x select 0)) ctrlSetTextColor ([[1,1,1,0.6], [1,1,1,1]] select (_kind == (_x select 1)));
        } forEach [[92807, "FORTIFICATION"], [92808, "SUPPLY"], [92810, "STATIC"], [92811, "VEHICLE"]];
        ["filter"] call ALiVE_fnc_buildMenu;
    };

    // Search (#1085): the category's items whose name or class name has the typed text in it
    // and the tier filter: 0 what this FOB can build now, 1 to 3 the items that need that tier, 9 all
    case "filter": {
        if (isNull BW_DISPLAY || {uiNamespace getVariable ["ALiVE_FOB_buildFilling", false]}) exitWith {};
        private _find = toLower (ctrlText (BW_DISPLAY displayCtrl 92812));
        private _rows = uiNamespace getVariable ["ALiVE_FOB_buildAll", []];
        if (_find != "") then {
            _rows = _rows select { ((toLower (_x select 1)) find _find) >= 0 || {((toLower (_x select 0)) find _find) >= 0} };
        };
        private _fobTier = (call _fnc_fob) param [5, 1];
        private _combo = BW_DISPLAY displayCtrl 92814;
        private _pick = if (lbCurSel _combo < 0) then { 0 } else { _combo lbValue (lbCurSel _combo) };
        _rows = _rows select {
            private _t = _x param [5, 1];
            switch (_pick) do { case 0: { _t <= _fobTier }; case 9: { true }; default { _t == _pick } }
        };
        uiNamespace setVariable ["ALiVE_FOB_buildRows", _rows];
        private _list = BW_DISPLAY displayCtrl 92802;
        lbClear _list;
        // nothing to show: no item to describe or place
        if (_rows isEqualTo []) then {
            (BW_DISPLAY displayCtrl 92803) ctrlSetStructuredText parseText "";
            (BW_DISPLAY displayCtrl 92809) ctrlSetText "";
            (BW_DISPLAY displayCtrl 92805) ctrlEnable false;
        };
        {
            _x params ["_class", "_name", "", "_cost", "", ["_tierMin", 1]];
            private _i = _list lbAdd format ["%1  (%2)", [_name, _class] select (_name == ""), _cost];
            if (_tierMin > _fobTier) then {
                _list lbSetColor [_i, [0.6, 0.6, 0.6, 1]];
                _list lbSetTextRight [_i, format [localize "STR_ALIVE_FOB_UI_TIER_SHORT", _tierMin]];
            };
            private _icon = getText (configFile >> "CfgVehicles" >> _class >> "icon");
            if (isText (configFile >> "CfgVehicleIcons" >> _icon)) then { _icon = getText (configFile >> "CfgVehicleIcons" >> _icon) };
            if (_icon != "" && {"\" in _icon}) then { _list lbSetPicture [_i, _icon] };
        } forEach _rows;
        _list lbSetCurSel 0;
        call _fnc_status;
    };

    case "select": {
        if (isNull BW_DISPLAY) exitWith {};
        private _row = (uiNamespace getVariable ["ALiVE_FOB_buildRows", []]) param [lbCurSel (BW_DISPLAY displayCtrl 92802), []];
        if (_row isEqualTo []) exitWith {};
        _row params ["_class", "_name", "_kind", "_cost", "_pic", ["_tierMin", 1]];
        (BW_DISPLAY displayCtrl 92809) ctrlSetText _pic;
        private _what = switch (_kind) do { case "SUPPLY": {"STR_ALIVE_FOB_UI_SUPPLY_ITEM"}; case "STATIC": {"STR_ALIVE_FOB_UI_STATIC_ITEM"}; case "VEHICLE": {"STR_ALIVE_FOB_UI_VEHICLE_ITEM"}; default {"STR_ALIVE_FOB_UI_FORTIFICATION"} };
        private _lines = [[_name, _class] select (_name == ""), localize _what, format [localize "STR_ALIVE_FOB_UI_COST", _cost]];
        private _locked = _tierMin > ((call _fnc_fob) param [5, 1]);
        if (_locked) then { _lines pushBack format [localize "STR_ALIVE_FOB_UI_TIER_NEEDED", _tierMin] };
        // a greyed item can be looked at but not placed
        (BW_DISPLAY displayCtrl 92805) ctrlEnable !_locked;
        (BW_DISPLAY displayCtrl 92803) ctrlSetStructuredText ([_lines, true] call _fnc_lines);
        call _fnc_status;
    };

    case "place": {
        if (isNull BW_DISPLAY) exitWith {};
        private _row = (uiNamespace getVariable ["ALiVE_FOB_buildRows", []]) param [lbCurSel (BW_DISPLAY displayCtrl 92802), []];
        private _fob = call _fnc_fob;
        if (_row isEqualTo [] || {_fob isEqualTo []}) exitWith {};
        // a double click on a greyed item does nothing, as the Place button does
        if ((_row param [5, 1]) > (_fob param [5, 1])) exitWith {};
        closeDialog 0;
        ["start", [_row, _fob]] call ALiVE_fnc_fobPlacement;
    };

    case "status": {
        call _fnc_status;
    };

    case "closed": {
        uiNamespace setVariable ["ALiVE_FOB_buildRows", []];
        uiNamespace setVariable ["ALiVE_FOB_buildAll", []];
    };
};
