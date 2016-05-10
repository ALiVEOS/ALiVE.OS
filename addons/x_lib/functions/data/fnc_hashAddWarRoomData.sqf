#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(hashAddWarRoomData);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashAddWarRoomData

Description:
Adds appropriate data to a hash for processing by War Room

Parameters:
Array - hash

Returns:
Array - The new hash

Examples:
(begin example)
_result = [_hash] call ALiVE_fnc_hashAddWarRoomData;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

private ["_gametime","_realTime","_groupID","_operation","_currenttime","_minutes","_hours","_hash"];

_hash = _this select 0;

// Get local time and format please.
_currenttime = date;

// Work out time in 4 digits
if ((_currenttime select 4) < 10) then {
	_minutes = "0" + str(_currenttime select 4);
} else {
	_minutes = str(_currenttime select 4);
	};
if ((_currenttime select 3) < 10) then {
	_hours = "0" + str(_currenttime select 3);
} else {
	_hours = str(_currenttime select 3);
};

_gametime = format["%1%2", _hours, _minutes];
_realTime = [] call ALIVE_fnc_getServerTime;

_groupID = [] call ALIVE_fnc_getGroupID;

_operation = getText (missionConfigFile >> "OnLoadName");

if (_operation == "") then {
		_operation = missionName;
};

[_hash, "gameTime", _gametime] call ALIVE_fnc_hashSet;
[_hash, "realTime", _realTime] call ALIVE_fnc_hashSet;
[_hash, "Group", _groupID] call ALIVE_fnc_hashSet;
[_hash, "Operation", _operation] call ALIVE_fnc_hashSet;
[_hash, "Map", worldName] call ALIVE_fnc_hashSet;


_hash