#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenATOAircraftSlotChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenATOAircraftSlotChoiceLoad

Description:
    Eden attributeLoad handler for ALiVE_ATOAircraftSlotChoice. Populates a
    single-select listbox with every aircraft belonging to the module's own
    faction, then wires two cycle buttons:

    - FilterNext (idc 1210) cycles SLOTS, one per Virtual Air Base slot.
      Each slot stores one aircraft classname, or nothing at all, which
      means the commander picks for that slot.
    - SideFilterNext (idc 1211) cycles the FAMILY filter: All, Fixed wing,
      Rotary. The button is inherited from the faction picker this control
      descends from, where it filtered by side; there is only one side here,
      so it earns its place filtering by what the aircraft is instead.

    LBSelChanged on the listbox stores the clicked row's lbData under the
    current slot index in the display namespace's `alive_slotSelections`
    array. Cycling the slot re-populates the listbox and re-ticks whatever
    that slot already holds.

    The first row is always Auto, whose lbData is the empty string. A slot
    with nothing stored starts on it.

    Storage shape:
      STRING, one token per slot, pipe-separated, e.g.
        "B_Plane_CAS_01_F||O_Heli_Attack_02_F|"
      An empty token is a slot left on Auto, so an untouched picker
      serialises as pipes alone.

Parameters:
    [_display, _varName, _slotCount, _factionVar, _sqmValue, _titleStr]

    _display    : DISPLAY - controlsGroup display
    _varName    : STRING  - logic variable the tokens are stored under
    _slotCount  : NUMBER  - how many slots to offer
    _factionVar : STRING  - logic variable holding the module's faction
    _sqmValue   : STRING  - SQM-deserialised value (Cfg3DEN's `_value`)
    _titleStr   : STRING  - localised title text or $STR_ key, rendered
                            in the Title sub-control (idc 101)

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "ingressSlotClasses";
private _slotCount = 12;
private _factionVar = "faction";
private _sqmValue  = "";
private _titleStr  = "Virtual Air Base Slot Aircraft:";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "SCALAR"} && {(_this select 2) > 0}) then {
        _slotCount = _this select 2;
    };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"} && {(_this select 3) != ""}) then {
        _factionVar = _this select 3;
    };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _sqmValue = _this select 4; };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"} && {(_this select 5) != ""}) then {
        _titleStr = _this select 5;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE ATOAircraftSlotChoice LOAD: null display"] call ALiVE_fnc_dump;
};

// ---- Title sub-control ----------------------------------------------------
private _titleResolved = _titleStr;
if (_titleStr != "" && {(_titleStr select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText _titleResolved;
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE ATOAircraftSlotChoice LOAD: listbox control (idc 100) not found"] call ALiVE_fnc_dump;
};

private _filterNextCtrl     = _display controlsGroupCtrl 1210;
private _sideFilterNextCtrl = _display controlsGroupCtrl 1211;

// ---- Resolve the module's faction -----------------------------------------
//
// Read off the selected logic, which is where the faction dropdown writes it.
// That means the list reflects the faction the module was last SAVED with, not
// whatever is showing in the dropdown at this instant - Eden hands each
// attribute its own load pass and they do not observe each other.
private _selectedLogic = get3DENSelected "logic";
private _logicObj = if (count _selectedLogic > 0) then { _selectedLogic select 0 } else { objNull };

private _faction = "";
if (!isNull _logicObj) then {
    private _stored = _logicObj getVariable [_factionVar, ""];
    if (typeName _stored == "STRING") then { _faction = _stored; };
};
// The air commander's own default, so a module placed and never touched lists
// the aircraft it would actually fly.
if (_faction == "") then { _faction = "OPF_F"; };

// ---- Resolve stored value -------------------------------------------------
//
// Priority order:
//   a) _sqmValue (engine-auto-populated)
//   b) logic getVariable _varName (mission previously saved)
//   c) the display's own value slot
//   d) nothing, which leaves every slot on Auto
private _slotSelections = [];
for "_i" from 0 to (_slotCount - 1) do { _slotSelections pushBack ""; };

private _raw = "";
if (_sqmValue != "") then {
    _raw = _sqmValue;
} else {
    if (!isNull _logicObj) then {
        private _stored = _logicObj getVariable [_varName, ""];
        if (typeName _stored == "STRING") then { _raw = _stored; };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

if (_raw != "") then {
    private _parts = _raw splitString "|";
    {
        if (_forEachIndex < _slotCount) then {
            _slotSelections set [_forEachIndex, _x];
        };
    } forEach _parts;
};

// ---- Walk CfgVehicles for this faction's aircraft -------------------------
//
// Each row: [displayName, classname, isPlane, isHeli]. Display name leads so a
// plain array sort orders the list the way the user reads it, which is how the
// faction picker this descends from does its ordering too.
//
// Drones are left out on purpose. They are placed by their own setting on the
// air commander, they carry no aircrew, and a slot is an airframe with a crew
// standing beside it - so offering them here would name a thing the Virtual
// Air Base does not build.
private _allRows = [];
{
    private _cfg = _x;
    private _classname = configName _cfg;

    if (_classname != "" && {getNumber (_cfg >> "scope") >= 1}) then {
        if (getText (_cfg >> "faction") == _faction && {_classname isKindOf "Air"}) then {

            private _isDrone = (_classname isKindOf "UAV")
                            || {getNumber (_cfg >> "isUav") == 1};

            if (!_isDrone) then {
                private _displayName = getText (_cfg >> "displayName");
                if (_displayName == "") then { _displayName = _classname; };
                _allRows pushBack [
                    _displayName,
                    _classname,
                    _classname isKindOf "Plane",
                    _classname isKindOf "Helicopter"
                ];
            };
        };
    };
} forEach ("true" configClasses (configFile >> "CfgVehicles"));

// Mods routinely give several airframes the same display name - a gunship and
// its desert repaint read identically - and a list with three rows called the
// same thing cannot be chosen from. Where a name is shared, show the classname
// alongside it. Names that are already unique are left clean.
{
    private _thisName = _x select 0;
    private _shared = ({(_x select 0) == _thisName} count _allRows) > 1;
    if (_shared) then {
        _x set [0, format ["%1 (%2)", _thisName, _x select 1]];
    };
} forEach _allRows;

// Alphabetical by display name, which is element 0.
_allRows sort true;

// ---- Filter cycle state ---------------------------------------------------
//
// alive_currentSlot   : NUMBER - which slot's tick the listbox shows
// alive_familyMode    : STRING "ALL" / "PLANE" / "HELI"
// alive_slotSelections: ARRAY of _slotCount STRINGs - per-slot picks
// alive_populating    : BOOL - LBSelChanged gate flag (true while LOAD is
//                       repopulating the listbox - the handler short-circuits
//                       to avoid recording a phantom user-click during
//                       programmatic ticks).
_display setVariable ["alive_currentSlot", 0];
_display setVariable ["alive_familyMode", "ALL"];
_display setVariable ["alive_slotSelections", _slotSelections];
_display setVariable ["alive_populating", false];
_display setVariable ["alive_allRows", _allRows];
_display setVariable ["alive_slotCount", _slotCount];

// ---- Populate function ----------------------------------------------------
private _populateFn = {
    params ["_display"];
    private _listCtrl = _display controlsGroupCtrl 100;
    if (isNull _listCtrl) exitWith {};

    private _allRows        = _display getVariable ["alive_allRows", []];
    private _slotSelections = _display getVariable ["alive_slotSelections", []];
    private _currentSlot    = _display getVariable ["alive_currentSlot", 0];
    private _familyMode     = _display getVariable ["alive_familyMode", "ALL"];
    private _slotCount      = _display getVariable ["alive_slotCount", 12];

    _display setVariable ["alive_populating", true];

    lbClear _listCtrl;
    private _selectedClass = _slotSelections param [_currentSlot, ""];

    // Auto first, and always visible whatever the family filter says - it is
    // not an aircraft, it is the absence of a choice.
    private _autoIdx = _listCtrl lbAdd "Auto (random suitable aircraft)";
    _listCtrl lbSetData [_autoIdx, ""];
    private _selectedIdx = _autoIdx;

    {
        _x params ["_displayName", "_classname", "_isPlane", "_isHeli"];

        private _show = switch (_familyMode) do {
            case "PLANE": { _isPlane };
            case "HELI":  { _isHeli };
            default       { true };
        };

        if (_show) then {
            private _idx = _listCtrl lbAdd _displayName;
            _listCtrl lbSetData [_idx, _classname];
            if (_classname == _selectedClass) then {
                _selectedIdx = _idx;
            };
        };
    } forEach _allRows;

    _listCtrl lbSetCurSel _selectedIdx;

    // Update labels.
    private _filterLabelCtrl     = _display controlsGroupCtrl 1200;
    private _sideFilterLabelCtrl = _display controlsGroupCtrl 1201;
    if (!isNull _filterLabelCtrl) then {
        _filterLabelCtrl ctrlSetText format ["Slot: %1 of %2", _currentSlot + 1, _slotCount];
    };
    if (!isNull _sideFilterLabelCtrl) then {
        private _familyLabel = switch (_familyMode) do {
            case "PLANE": { "Fixed wing" };
            case "HELI":  { "Rotary" };
            default       { "All" };
        };
        _sideFilterLabelCtrl ctrlSetText format ["Family: %1", _familyLabel];
    };

    _display setVariable ["alive_populating", false];
};

// Store the populate function so handlers can re-invoke it.
_display setVariable ["alive_populateFn", _populateFn];

// ---- Initial populate -----------------------------------------------------
[_display] call _populateFn;

// ---- LBSelChanged handler -------------------------------------------------
//
// Records the clicked row's classname under the current slot index.
// Suppressed during programmatic populate via alive_populating gate on the
// controlsGroup display (stored as `alive_disp` on the listbox so the handler
// can recover the controlsGroup without relying on ctrlParent - which returns
// the topmost Eden dialog, not the controlsGroup).
_listCtrl setVariable ["alive_disp", _display];
_listCtrl ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_selIdx"];
    private _disp = _ctrl getVariable "alive_disp";
    if (isNull _disp) exitWith {};
    if (_disp getVariable ["alive_populating", false]) exitWith {};
    if (_selIdx < 0) exitWith {};

    // An empty classname is the Auto row, and it is a real choice - it clears
    // the slot - so unlike the faction picker this must not be discarded.
    private _classname = _ctrl lbData _selIdx;
    if (typeName _classname != "STRING") exitWith {};

    private _slotSelections = _disp getVariable ["alive_slotSelections", []];
    private _currentSlot    = _disp getVariable ["alive_currentSlot", 0];
    private _slotCount      = _disp getVariable ["alive_slotCount", 12];
    while {count _slotSelections < _slotCount} do { _slotSelections pushBack ""; };
    _slotSelections set [_currentSlot, _classname];
    _disp setVariable ["alive_slotSelections", _slotSelections];
}];

// ---- Slot cycle button (idc 1210) -----------------------------------------
//
// State recovered via setVariable on the button itself rather than via
// ctrlParent. Same rationale as the listbox handler above.
if (!isNull _filterNextCtrl) then {
    _filterNextCtrl setVariable ["alive_disp", _display];
    _filterNextCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_btn"];
        private _disp = _btn getVariable "alive_disp";
        if (isNull _disp) exitWith {};
        private _currentSlot = _disp getVariable ["alive_currentSlot", 0];
        private _slotCount   = _disp getVariable ["alive_slotCount", 12];
        _currentSlot = (_currentSlot + 1) mod _slotCount;
        _disp setVariable ["alive_currentSlot", _currentSlot];
        private _populateFn = _disp getVariable ["alive_populateFn", {}];
        [_disp] call _populateFn;
    }];
};

// ---- Family filter cycle button (idc 1211) --------------------------------
if (!isNull _sideFilterNextCtrl) then {
    _sideFilterNextCtrl setVariable ["alive_disp", _display];
    _sideFilterNextCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_btn"];
        private _disp = _btn getVariable "alive_disp";
        if (isNull _disp) exitWith {};
        private _familyMode = _disp getVariable ["alive_familyMode", "ALL"];
        _familyMode = switch (_familyMode) do {
            case "ALL":   { "PLANE" };
            case "PLANE": { "HELI" };
            default       { "ALL" };
        };
        _disp setVariable ["alive_familyMode", _familyMode];
        private _populateFn = _disp getVariable ["alive_populateFn", {}];
        [_disp] call _populateFn;
    }];
};

[
    "ALIVE ATOAircraftSlotChoice LOAD: varName='%1' faction='%2' raw='%3' slots=%4 rows=%5",
    _varName,
    _faction,
    _raw,
    str _slotSelections,
    count _allRows
] call ALiVE_fnc_dump;
