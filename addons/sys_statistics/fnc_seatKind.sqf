#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ALIVE_sys_statistics_fnc_seatKind

Description:
The seat a player took or left, for the War Room's records, so a pilot can be told from a passenger.
The engine's own seat name is too coarse: a helicopter's copilot and its door gunners both come through
as a turret, and a seat a passenger can shoot from is a turret too.

Parameters:
Object - the vehicle
String - the seat as the GetIn / GetOut event gives it ("driver", "gunner", "commander", "turret", "cargo")
Array - the turret path the event gives ([] when not a turret)

Returns:
String - pilot, copilot, driver, gunner, commander, turret or cargo

Examples:
(begin example)
[_vehicle, _position, _turret] call ALIVE_sys_statistics_fnc_seatKind;
(end)

Author:
Jman
---------------------------------------------------------------------------- */
params [["_vehicle", objNull, [objNull]], ["_role", "", [""]], ["_turret", [], [[]]]];
_role = toLower _role;
if (_role == "driver") exitWith { ["driver", "pilot"] select (_vehicle isKindOf "Air") };
if (_turret isEqualTo [] || {isNull _vehicle}) exitWith {
    if (_role in ["gunner", "commander", "cargo"]) then { _role } else { "cargo" }
};
private _cfg = [_vehicle, _turret] call BIS_fnc_turretConfig;
switch (true) do {
    case (getNumber (_cfg >> "isCopilot") == 1): { "copilot" };
    // before the passenger test: a tank commander turned out can fire his own weapon too
    case (getNumber (_cfg >> "primaryObserver") == 1): { "commander" };
    case (getNumber (_cfg >> "primaryGunner") == 1): { "gunner" };
    // a seat a passenger rides in and fires their own weapon from
    case (getNumber (_cfg >> "isPersonTurret") > 0): { "cargo" };
    default { "turret" };
};
