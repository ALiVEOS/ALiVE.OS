#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileKilledEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileKilledEventHandler

Description:
Killed event handler for profile units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["Killed", ALIVE_fnc_profileKilledEventHandler];
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
if (!isserver) exitwith {};

params ["_unit","_killer"];

private _profileID = _unit getvariable "profileID";
private _profile = [ALIVE_profileHandler,"getProfile", _profileID] call ALIVE_fnc_profileHandler;

if (isnil "_profile") exitwith {};

private _profileType = _profile select 2 select 5; // [_profile, "type"] call ALIVE_fnc_hashGet;

switch(_profileType) do {
    case "entity": {
        private _allProfileUnitsDead = [_profile,"handleDeath", _unit] call ALIVE_fnc_profileEntity;

        if !(_allProfileUnitsDead) then {
            [ALIVE_profileHandler,"unregisterProfile", _profile] call ALIVE_fnc_profileHandler;

            // log event

            private _position = _profile select 2 select 2;
            private _faction = _profile select 2 select 29;
            private _side = _profile select 2 select 3;

            private _killerSide = str(side group _killer);
            private _killerProfileID = _killer getvariable "profileID";
            private _killerProfile = [ALIVE_profileHandler,"getProfile", _killerProfileID] call ALIVE_fnc_profileHandler;

            private _event = ['PROFILE_KILLED', [_position,_faction,_side,_killerSide,_profile,_killerProfile], "Profile"] call ALIVE_fnc_event;
            private _eventID = [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;
        };
    };
    case "vehicle": {
        [_profile, "handleDeath"] call ALIVE_fnc_profileVehicle;
        // not sure about this, it will remove the profile and the vehicle wreck will remain
        // will need to have dead vehicle cleanup scripts
        [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
    };
};