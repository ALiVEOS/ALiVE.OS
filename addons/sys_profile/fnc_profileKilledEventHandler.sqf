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

            private _victimProfileID = _profile select 2 select 4;
            private _victimObjectType = _profile select 2 select 6;

            private _event = ['PROFILE_KILLED', [_position,_faction,_side,_killerSide,_profile,_killerProfile,_victimProfileID,_victimObjectType], "Profile"] call ALIVE_fnc_event;
            private _eventID = [ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;
        };
    };
    case "vehicle": {
        [_profile, "handleDeath"] call ALIVE_fnc_profileVehicle;

        // Airframe-loss visibility: unlike the entity branch above, the vehicle branch unregisters a
        // killed vehicle profile SILENTLY (no PROFILE_KILLED event), so a destroyed ATO airframe left
        // NO rpt trace and had to be reverse-engineered from Un-Register lines + coordinates. Log AIR
        // profile deaths (rare enough not to spam) with position + killer so the destruction is one
        // grep away. RPT only (ALIVE_fnc_dump, no sidechat).
        private _vClass = _profile select 2 select 6;
        if (!isNil "_vClass" && {_vClass isEqualType ""} && {_vClass isKindOf "Air"}) then {
            private _vId  = _profile select 2 select 4;
            private _vPos = _profile select 2 select 2;
            private _killerType = if (isNull _killer) then {"unknown"} else {typeOf _killer};
            private _killerSide = if (isNull _killer) then {"?"} else {str side group _killer};
            ["ALIVE airframe-loss: %1 (%2) DESTROYED at %3 by %4 (side %5)", _vId, _vClass, _vPos, _killerType, _killerSide] call ALIVE_fnc_dump;
        };

        // not sure about this, it will remove the profile and the vehicle wreck will remain
        // will need to have dead vehicle cleanup scripts
        [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
    };
};