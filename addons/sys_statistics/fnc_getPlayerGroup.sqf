/* ----------------------------------------------------------------------------
Function: ALIVE_sys_stat_fnc_getPlayerGroup
Description:
Gets the player's group associated with the kill event

Parameters:
Object - unit that is killer or killed

Returns:
unit's player group

Attributes:
None

Parameters:
_this select 0: OBJECT - _unit



Examples:
(begin example)
	[_unit] call ALiVE_fnc_getPlayerGroup
(end)

See Also:
- <ALIVE_sys_stat_fnc_firedEH>
- <ALIVE_sys_stat_fnc_incomingMissileEH>
- <ALIVE_sys_stat_fnc_handleDamageEH>

Author:
Tupolov
---------------------------------------------------------------------------- */
// MAIN
#define DEBUG_MODE_FULL

#include "script_component.hpp"

private ["_playerGroup","_unit"];

_unit = _this select 0;

if !(_unit isKindof "Man") then {
	switch (true) do {
		case (isPlayer (commander _unit)) : {_playerGroup =	(commander _unit) getvariable [QGVAR(playerGroup), GVAR(groupTag)];};
		case (isPlayer (gunner _unit)) : {_playerGroup = (gunner _unit) getvariable [QGVAR(playerGroup), GVAR(groupTag)];};
		case (isPlayer (driver _unit)) : {_playerGroup = (driver _unit) getvariable [QGVAR(playerGroup), GVAR(groupTag)];};
		default {_playerGroup = _unit getvariable [QGVAR(playerGroup), GVAR(groupTag)];};
	};
} else {
	_playerGroup = _unit getvariable [QGVAR(playerGroup), GVAR(groupTag)];
};

_playerGroup
