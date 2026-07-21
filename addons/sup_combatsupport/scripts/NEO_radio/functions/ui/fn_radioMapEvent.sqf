private ["_map", "_button", "_pos"];
_map = _this select 0;
_button = _this select 1; if (_button == 1) exitWith {};
_pos = _map ctrlMapScreenToWorld [_this select 2, _this select 3];

// #630 reflect the clicked location back into the grid field so both inputs stay in sync
private _grid = [_pos] call NEO_fnc_radioPosToGrid;
if (_grid != "") then { ((findDisplay 655555) displayCtrl 655636) ctrlSetText _grid; };

// #630 the map-click and the additive grid-entry field both feed the same shared target-set logic
[_pos] call NEO_fnc_supportSetTargetPos;
