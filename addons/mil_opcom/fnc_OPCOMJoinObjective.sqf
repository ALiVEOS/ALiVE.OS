#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMjoinObjective);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMjoinObjective
Description:
Marks all objective of given state, lets you select your preferred one, and joins you to an attacking/defending section

Parameters:
OBJECT - unit
STRING - state (string of "attacking" or "defending")

Returns:
nothing

Attributes:
none

Examples:
(begin example)
[player,"attacking"] call ALIVE_fnc_OPCOMjoinObjective;
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_objectives","_color"];

params [
    ["_unit", player, [objNull]],
    ["_state", "attacking", [""]]
];

//Execute on Server only
if !(isServer) exitwith {
    hint "Requesting mission from OPCOM! Please have some patience, soldier!";
    [_unit,_state] remoteExec ["ALiVE_fnc_OPCOMjoinObjective",2];
};

_position = getposATL _unit;
_faction = faction _unit;

//Select OPCOM
{if ({_x == _faction} count ([_x,"factions",[]] call ALiVE_fnc_HashGet) > 0) exitwith {_logic = _x}} foreach OPCOM_instances;
	
switch (_state) do {
	case ("attacking") : {_color = "COLORRED"};
	case ("defending") : {_color = "COLORBLUE"};
};

_objectives = []; {_objectives pushback _x} foreach ([_logic,"nearestObjectives",[_position,_state]] call ALiVE_fnc_OPCOM);

[_logic,"joinObjectiveClient",[_unit,_objectives,_color]] call ALiVE_fnc_OPCOM;