#include <\x\alive\addons\mil_OPCOM\script_component.hpp>
SCRIPT(OPCOMjoinNearestGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMjoinNearestGroup
Description:
Joins the given unit to the nearest available group with given state! Use with spawn!

Parameters:
Object - unit
String - possible states "attacking" / "defending" / "reserving" (though "reserving" is not really useful)

Returns:
String - The nearest ProfileEntity ID

Examples:
(begin example)
// Join the player to the nearest group that is currently attacking an objective
[player,"attacking"] spawn ALiVE_fnc_OPCOMjoinNearestGroup;
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_profile","_profileUnit","_logic"];

params [
    ["_unit", objNull, [objNull]],
    ["_state", "attacking", [""]]
];

if (isNull _unit) exitwith {};

if !(isServer) exitwith {[_unit,_state] remoteExec ["ALiVE_fnc_OPCOMjoinNearestGroup",2]};

titleText ["Teleporting...", "BLACK OUT",3]; // this is executing visual stuff on server, should be removed
{titleText ['Teleporting...', 'BLACK OUT',3]} remoteExec ["BIS_fnc_Spawn",owner _unit];

_faction = faction _unit;
_pos = getposATL _unit;
_groupUnits = units (group _unit);

{if ({_x == _faction} count ([_x,"factions",[]] call ALiVE_fnc_HashGet) > 0) exitwith {_logic = _x}} foreach OPCOM_instances;

if (isnil "_logic") exitwith {};

_entityID = [_logic,"nearestEntity",[_unit,_state]] call ALiVE_fnc_OPCOM; if (isnil "_entityID") exitwith {};
_profileID = _unit getvariable "profileID"; if (isnil "_profileID") exitwith {};

_profile = [ALiVE_ProfileHandler,"getProfile",_entityID] call ALiVE_fnc_ProfileHandler; if (isnil "_profile") exitwith {};
_profileUnit = [ALiVE_ProfileHandler,"getProfile",_profileID] call ALiVE_fnc_ProfileHandler; if (isnil "_profileUnit") exitwith {};

_pos = [_profile,"position"] call ALiVE_fnc_HashGet;

sleep 4;

{_x setposATL _pos} foreach _groupUnits;
waituntil {sleep 1; [_profile,"active"] call ALiVE_fnc_HashGet}; 

sleep 1;

_units = [_profile,"units"] call ALIVE_fnc_hashGet;
_group = group (_units select 0);

_groupUnits join _group; {_x setposATL formationPosition _x} foreach _groupUnits;

//Clone waypoints of joined entity
[_profileUnit, "clearWaypoints"] call ALIVE_fnc_profileEntity; {[_profileUnit, "addWaypoint", _x] call ALIVE_fnc_profileEntity} foreach ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet);

titleText ["Teleporting...", "BLACK IN",3];
{titleText ['Teleporting...', 'BLACK IN',3]} remoteExec ["BIS_fnc_Spawn",owner _unit];

_entityID;