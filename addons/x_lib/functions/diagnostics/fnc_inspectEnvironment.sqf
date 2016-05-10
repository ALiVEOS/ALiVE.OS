#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(inspectEnvironment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_inspectEnvironment

Description:
Inspect current world environment to the RPT

Parameters:

Returns:

Examples:
(begin example)
// inspect config class
[] call ALIVE_fnc_inspectEnvironment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_text","_date"];
	
_text = " ------------------ Inspecting Environment -------------------- ";
[_text] call ALIVE_fnc_dump;

[" world: %1", worldName] call ALIVE_fnc_dump;

[" mission: %1", missionName] call ALIVE_fnc_dump;

[" is server: %1", isServer] call ALIVE_fnc_dump;

[" is dedicated server: %1", isDedicated] call ALIVE_fnc_dump;

_date = date;
[" date: %1-%2-%3 %4:%5", _date select 0, _date select 1, _date select 2, _date select 3, _date select 4] call ALIVE_fnc_dump;

[" time: %1", daytime] call ALIVE_fnc_dump;	

[" overcast: %1", overcast] call ALIVE_fnc_dump;

[" fog: %1", fog] call ALIVE_fnc_dump;

[" rain: %1", rain] call ALIVE_fnc_dump;

[" rainbow: %1", rainbow] call ALIVE_fnc_dump;

[" lightnings: %1", lightnings] call ALIVE_fnc_dump;

[" humidity: %1", humidity] call ALIVE_fnc_dump;

[" gusts: %1", gusts] call ALIVE_fnc_dump;

[" waves: %1", waves] call ALIVE_fnc_dump;

[" wind direction: %1", windDir] call ALIVE_fnc_dump;

[" wind strength: %1", windStr] call ALIVE_fnc_dump;

[" next weather change: %1", nextWeatherChange] call ALIVE_fnc_dump;

[" fog forecast: %1", fogForecast] call ALIVE_fnc_dump;

[" overcast forecast: %1", overcastForecast] call ALIVE_fnc_dump;

_text = " ------------------ Inspection Complete -------------------- ";
[_text] call ALIVE_fnc_dump;