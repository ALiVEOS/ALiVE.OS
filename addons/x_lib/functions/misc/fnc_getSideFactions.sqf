#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getSideFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getSideFactions

Description:
Returns factions of given side

Parameters:
String - side

Returns:
Array - factions

Examples:
(begin example)
_factions = "CIV" call ALiVE_fnc_getSideFactions;
(end)

See Also:
- nil

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_factions","_side"];

_side = _this;

_factions = [];

_factionClasses = (configFile >> "CfgFactionClasses");

for "_i" from 1 to (count _factionClasses - 1) do {
	private ["_element","_classSide"];
	_element = _factionClasses select _i;
	if (isclass _element) then {
		_classSide = getnumber(_element >> "side");
		if (_classSide == [_side] call ALIVE_fnc_sideTextToNumber) then {
			_factions = _factions + [configname _element];
		};
	};
};


_factions