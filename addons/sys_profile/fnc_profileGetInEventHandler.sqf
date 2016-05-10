#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetInEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileGetInEventHandler

Description:
Get in event handler for profile units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["GetIn", ALIVE_fnc_profileGetInEventHandler];
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_unit","_getInUnit","_profileID","_profile"];
	
_unit = _this select 0;
_getInUnit = _this select 2;

if(isPlayer _getInUnit) then {
    _profileID = _unit getVariable "profileID";
    _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

    if (isnil "_profile") exitwith {};

    [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
};

