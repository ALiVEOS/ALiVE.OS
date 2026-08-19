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
            // Where it ACTUALLY died. The profile's stored position is only refreshed at spawn/despawn
            // and by the virtual simulator, so for a live flying aircraft it still holds the spot it
            // took off from - which made three in-flight crashes 2km out read as if they had happened
            // on their own parking spots, to the centimetre. Read the object.
            private _vPos = if (!isNull _unit) then { getPosATL _unit } else { _profile select 2 select 2 };
            private _killerType = if (isNull _killer) then {"unknown"} else {typeOf _killer};
            private _killerSide = if (isNull _killer) then {"?"} else {str side group _killer};
            // Disambiguate the loss so the RPT is not left to interpretation (which caused fixes
            // for events that never happened). The extra fields tell the four cases apart:
            //   self=true, dist~0            -> SELF-inflicted (own crew crashed it, e.g. clipping a
            //                                   hangar on taxi-out); killerVeh == the victim's class.
            //   self=false, small dist,
            //     killerVeh a DIFFERENT air  -> a genuine two-aircraft collision (that IS the partner).
            //   self=false, large dist,
            //     enemy side                 -> ranged / enemy fire.
            //   by unknown (side ?)          -> null killer -> static object / terrain / wreck hit.
            // nearBldg flags a structure at the death spot (tent-hangar clips read as insideBldg here).
            private _self      = (!isNull _killer) && {(_killer == _unit) || {_killer in crew _unit} || {(vehicle _killer) == _unit}};
            private _killerVeh = if (isNull _killer) then {"none"} else {typeOf (vehicle _killer)};
            private _killerDist = if (isNull _killer) then {-1} else {round (_killer distance _unit)};
            private _nearBldg  = (nearestObjects [(getPosATL _unit), ["Building","House"], 6]) apply {typeOf _x};
            ["ALIVE airframe-loss: %1 (%2) DESTROYED at %3 by %4 (side %5) [self=%6 killerVeh=%7 dist=%8m victimSpeed=%9 nearBldg=%10]", _vId, _vClass, _vPos, _killerType, _killerSide, _self, _killerVeh, _killerDist, round (speed _unit), _nearBldg] call ALIVE_fnc_dump;
        };

        // not sure about this, it will remove the profile and the vehicle wreck will remain
        // will need to have dead vehicle cleanup scripts
        [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
    };
};