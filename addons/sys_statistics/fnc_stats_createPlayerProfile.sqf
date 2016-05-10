/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_stats_createPlayerProfile

Description:
Adds a player diary record with their current website profile

Parameters:
Array - Array of key/value pairs

Returns:
Bool - success or failure

Examples:
(begin example)
	[ _data ] call ALIVE_fnc_stats_createPlayerProfile;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(stats_createPlayerProfile);

private ["_result","_profile","_data","_msg","_profile","_playerGroup","_username"];

TRACE_1("CREATING PLAYER PROFILE", _this);

_data = _this select 0;
_profile = "";

if ([_data] call ALIVE_fnc_isHash) then {

	// Grab Player's serverGroup
	_playerGroup = [_data, "Server Group", "Unknown"] call ALIVE_fnc_hashGet;
	_username = [_data, "Username", "Unknown"] call ALIVE_fnc_hashGet;

	player setVariable [QGVAR(playerGroup), _playerGroup, true];

	// Create a Player diary record
	player createDiarySubject ["statsPage","ALiVE"];

	_prof = {
		_profile = _profile + _key + " : " + str _value + "<br />";
	};

	[_data, _prof] call CBA_fnc_hashEachPair;

	player createDiaryRecord ["statsPage", ["Profile",
	"<br/><img size='7' image='\x\alive\addons\UI\logo_alive_crop.paa' /><br/><br/><t color='#ffff00' size='1.0' shadow='1' shadowColor='#000000' align='center'>ALiVE War Room Profile: " + _username + "</t><br/><br/><t align='left'>" + _profile + "</t><br/><br/>"
	]];

	_msg = format["Welcome %1!", name player];

	[_msg, "Profile download from ALiVE website completed. Your ALiVE web profile is now available in player diary under the entry ALiVE > Profile."] call ALIVE_fnc_sendHint;

	_result = true;

} else {

	_msg = format["Welcome %1!", name player];

	[_msg, "Unfortunately we were unable to download your Profile from the ALiVE website. Either something is broken, or you have not registered at alivemod.com. Please do so as soon as possible so you can access the ALiVE War Room and your own personal stats."] call ALIVE_fnc_sendHint;

	TRACE_1("NOT CREATING PLAYER PROFILE - NO VALID DATA", _data);

	_result = false;
};


_result;


