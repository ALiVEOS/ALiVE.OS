#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenDroneChoiceMultiLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenDroneChoiceMultiLoad

Description:
    Eden attributeLoad handler for ALiVE_DroneChoiceMulti. Lists every drone
    the loaded content provides and ticks the ones already chosen.

    Unlike the other filtered pickers, the rows here are NOT read from a
    curated registry. Drones can be identified from config outright: the isUav
    property resolves through inheritance, so a single scan finds them all and
    any mod is covered the moment it loads, with nothing to maintain by hand.

    That property is also the only reliable test. Checking isKindOf "UAV"
    misses the small rotary reconnaissance drones, whose base inherits from the
    helicopter chain rather than from UAV, and those are exactly the ones worth
    listing.

    AN EMPTY SELECTION IS MEANINGFUL HERE and must be left alone. Blank means
    "use whatever drones the faction lists", which is the sensible default for
    most missions. This deliberately does NOT pre-tick rows when nothing is
    stored, which is the opposite of the mission-types picker, where an empty
    list meant a commander that silently flew nothing.

Parameters:
    [_display, _varName, _titleText, _sqmValue]
    _display   : DISPLAY - Eden attribute display (controlsGroup)
    _varName   : STRING  - logic variable name. Defaults to "droneTypes".
    _titleText : STRING  - label for the Title sub-control. A "$" prefix is
                           resolved through the stringtable.
    _sqmValue  : STRING  - engine-populated value via Cfg3DEN's `_value`.

Returns:
    nil

See Also:
    ALIVE_fnc_edenSideChoiceMultiSave - reused as this control's attributeSave;
    it is token-agnostic, reading lbData off the selected rows and joining with
    commas.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "droneTypes";
private _titleText = "$STR_ALIVE_ATO_DRONE_TYPES";
private _sqmValue  = "";

if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"} && {(_this select 2) != ""}) then {
        _titleText = _this select 2;
    };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then {
        _sqmValue = _this select 3;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE DroneChoiceMulti LOAD: null display"] call ALiVE_fnc_dump;
};

private _titleResolved = _titleText;
if (_titleText != "" && {(_titleText select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleText select [1]);
};

private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText _titleResolved;
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE DroneChoiceMulti LOAD: listbox control (idc 100) not found"] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// Build the rows from config. One engine-side pass rather than walking
// CfgVehicles in script - with a large modset this is the difference between
// opening the attributes window and appearing to hang.
//
// scope >= 2 keeps out the base and hidden classes that would otherwise
// clutter the list with entries nobody can use.
// ------------------------------------------------------------------------
private _droneCfgs = "getNumber (_x >> 'isUav') == 1 && {getNumber (_x >> 'scope') >= 2}" configClasses (configFile >> "CfgVehicles");

// Which side is this commander on? Read from the module's own faction so the
// list only offers drones it could actually field. Not always resolvable at
// this point - a module placed but never configured has no faction yet - so a
// failure here widens the list rather than emptying it.
private _wantSide = -1;
private _sideSource = "all sides (faction not resolved)";
private _logics = get3DENSelected "logic";
if (count _logics > 0) then {
    private _fac = (_logics select 0) getVariable ["faction", ""];
    if (_fac isEqualType "" && {_fac != ""}) then {
        // Resolved through ALiVE's own helper rather than reading
        // CfgFactionClasses directly: faction classes do not all live in the
        // same config root, and mil_ato resolves its own side the same way.
        private _facCfg = if (!isNil "ALiVE_fnc_configGetFactionClass") then {
            _fac call ALiVE_fnc_configGetFactionClass
        } else {
            configFile >> "CfgFactionClasses" >> _fac
        };
        if (!isNil "_facCfg" && {isNumber (_facCfg >> "side")}) then {
            _wantSide = getNumber (_facCfg >> "side");
            _sideSource = format ["faction %1 (side %2)", _fac, _wantSide];
        };
    };
};

private _rows = [];
{
    private _cls = configName _x;

    // Flyable only. isUav covers ground drones too - the UGV base descends from
    // Car_F - and this is the air commander, so a rover has no business here.
    if (_cls != "" && {_cls isKindOf "Air"}) then {

        // And only the commander's own side, when it is known. A vehicle whose
        // config declares no side is kept, since dropping it would lose
        // third-party content that simply omits the entry.
        private _clsSide = if (isNumber (_x >> "side")) then { getNumber (_x >> "side") } else { -1 };

        if (_wantSide < 0 || {_clsSide < 0} || {_clsSide == _wantSide}) then {
            private _label = getText (_x >> "displayName");
            if (_label == "") then { _label = _cls };
            _rows pushBack [_cls, format ["%1  (%2)", _label, _cls]];
        };
    };
} forEach _droneCfgs;

// Sorted by the visible label so the list reads alphabetically rather than in
// whatever order the configs happened to load.
_rows sort true;

private _canonical = _rows apply {_x select 0};

// ------------------------------------------------------------------------
// Resolve the stored value: engine value, then the logic variable, then the
// Eden save slot. No default is applied when all three are empty - see the
// note at the top; blank is a real choice here.
// ------------------------------------------------------------------------
private _raw = "";
if (_sqmValue != "") then {
    _raw = _sqmValue;
} else {
    private _logics = get3DENSelected "logic";
    if (count _logics > 0) then {
        private _stored = (_logics select 0) getVariable [_varName, ""];
        if (typeName _stored == "STRING") then {
            _raw = _stored;
        } else {
            if (typeName _stored == "ARRAY") then {
                _raw = (_stored apply {str _x}) joinString ",";
            };
        };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

// ------------------------------------------------------------------------
// Parse. Accepts comma-separated, array-literal, quoted or bare - the same
// permissive handling the mission-types field uses, so a value typed by hand
// into the old text box still loads.
//
// A stored class that no longer exists (a mod removed since the mission was
// saved) simply will not match a row, so it drops out quietly rather than
// leaving a tick against nothing.
// ------------------------------------------------------------------------
private _selected = [];
if (_raw != "") then {
    {
        private _t = toLower _x;
        if (_t != "") then {
            {
                if (toLower _x == _t && {!(_x in _selected)}) then {
                    _selected pushBack _x;
                };
            } forEach _canonical;
        };
    } forEach (_raw splitString "[]""', ");
};

lbClear _listCtrl;

{
    _x params ["_token", "_label"];
    private _idx = _listCtrl lbAdd _label;
    _listCtrl lbSetData [_idx, _token];
    if (_token in _selected) then {
        _listCtrl lbSetSelected [_idx, true];
    };
} forEach _rows;

// The filter source is logged because an unexpectedly short or empty list is
// otherwise indistinguishable from the picker being broken - it says whether
// the side filter engaged and what it filtered to.
[
    "ALIVE DroneChoiceMulti LOAD: varName='%1' raw='%2' candidates=%3 rows=%4 filter=%5 ticked=%6",
    _varName,
    _raw,
    count _droneCfgs,
    count _rows,
    _sideSource,
    count (lbSelection _listCtrl)
] call ALiVE_fnc_dump;
