/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_checkIsDiving
Description:
Checks to see if the unit is underwater on a combat dive and records the time they spent underwater

Parameters:
None

Returns:
Nothing

Attributes:
None

Parameters:
None


Examples:
(begin example)
	[MOD(fnc_checkIsDiving), 30, [GVAR(ENABLED)]] call CBA_fnc_addPerFrameHandler;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */
// MAIN
#define DEBUG_MODE_FULL

#include "script_component.hpp"

// Combat Dive - checks every 30 seconds for diving
private ["_diving", "_diveStartTime", "_diveTime", "_statsEnabled","_params"];

_params = _this select 0;
_statsEnabled = (_params select 0);

if (underwater player && isAbleToBreathe player) then {
	_diving = player getVariable [QGVAR(isDiving),false];

	// record dive start time
	if !(_diving) then {
		player setVariable [QGVAR(isDiving),true,false];
		player setVariable [QGVAR(diveStartTime),diag_tickTime,false];
	};
} else {

	_diving = player getVariable [QGVAR(isDiving),false];

	// Player has exited from dive - they may have surfaced also?
	if (_diving) then {

		_diveStartTime = player getVariable [QGVAR(diveStartTime),diag_tickTime - 45];
		_diveTime = round((diag_tickTime - _diveStartTime) / 60); // in minutes

		// Record Combat Dive
		if (_statsEnabled) then {
			[player,_diveTime] call GVAR(fnc_divingEH);
		};

		// Clear dive flag
		player setVariable [QGVAR(isDiving),false,false];
	};
};

