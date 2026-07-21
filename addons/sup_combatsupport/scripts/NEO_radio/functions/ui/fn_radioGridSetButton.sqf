// NEO_fnc_radioGridSetButton
// #630 Additive grid-entry: read the typed grid, convert it to a world position, and feed the SAME
// shared target-set logic the map-click uses. Fires from the Set button (and the edit's Enter key).
// The map-click path is untouched - this is a second input method, not a replacement.
// Author: Jman
private ["_edit", "_grid", "_pos", "_mapSize"];

// Gate on the exact same armed state the map-click requires. This is correctness, not cosmetics:
// the map-click handler is only ever attached once a ready unit is selected, and the
// *ConfirmButtonEnable functions do select (lbCurSel ...) on that unit list - so the grid path must
// honour the identical precondition or it can hit a -1 index the click path structurally avoids.
if !(uinamespace getVariable ["NEO_radioMapClickArmed", false]) exitWith {
    hint "Select a support unit first";
};

_edit = (findDisplay 655555) displayCtrl 655636;
_grid = ctrlText _edit;
_grid = (_grid splitString " ") joinString ""; // strip spaces - players type "0460 4900" (SQF has no string minus)

_pos = _grid call NEO_fnc_radioGridToPos;
if (_pos isEqualTo []) exitWith {
    hint "Enter an 8-digit grid (e.g. 0284 0172)";
};

// refuse a grid that lands off the map rather than silently placing the marker in the void
_mapSize = getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize");
if ((_pos select 0) < 0 || {(_pos select 0) > _mapSize} || {(_pos select 1) < 0} || {(_pos select 1) > _mapSize}) exitWith {
    hint "That grid is off the map";
};

[_pos] call NEO_fnc_supportSetTargetPos;
