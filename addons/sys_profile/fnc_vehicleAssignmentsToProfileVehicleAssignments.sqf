#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(vehicleAssignmentsToProfileVehicleAssignments);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleAssignmentsToProfileVehicleAssignments

Description:
Read a real vehicles assignments and return a profileVehicle assignments

Parameters:
Vehicle - The vehicle

Returns:

Examples:
(begin example)
// read all real vehicle assignments of a vehicle
[_vehicle] call ALIVE_fnc_vehicleAssignmentsToProfileVehicleAssignments;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_profile","_profileType","_profileID","_profileActive","_vehicle","_groupsInVehicle","_group","_units","_vehiclesUnitsIn","_leader",
"_entityID","_entityProfile","_entityProfileActive","_assignment","_vehicleAssignments","_vehicleID","_vehicleProfile","_vehicleProfileActive"];

_profile = _this select 0;

_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
_profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
_profileActive = _profile select 2 select 1; //[_profile,"active"] call ALIVE_fnc_hashGet;

// reset data. A vehicle lists the groups in it and a group the vehicles it's in, and each resets its own
// pair. Run on a group, this used to clear the vehicle's pair instead, so a vehicle its men had got out
// of stayed in the group's lists, and the simulator doesn't move a virtual group listed in one. A group
// on foot is back at walking pace; one still in a vehicle gets its lists and pace back from it below.
// every vehicle the group was linked to before the reset, from both its assignment list and its own vehicle
// lists: a link can sit in either, so the vehicles it has left can be told to drop it below
private _wasInIDs = +(([_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_hashGet) select 1);
if (_profileType != "vehicle") then {
    { _wasInIDs pushBackUnique _x } forEach (([_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashGet) + ([_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashGet));
};
[_profile,"vehicleAssignments",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
if (_profileType == "vehicle") then {
    [_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashSet;
    [_profile,"entitiesInCargoOf",[]] call ALIVE_fnc_hashSet;
} else {
    [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
    [_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
    [_profile,"speedPerSecond","Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet;
};

// Men riding only in the back of a vehicle another, pinned group crews (a Military Placement vehicle, a
// pinned post) are not linked to it. Linked, their whole group counted as its cargo: a patrol that had
// one man sitting in a placed M113 when it despawned took the M113 along on its patrol once virtual,
// and after a reload the M113's crew came back with the patrol's orders (RSS7, 16 Nov).
private _ridesOnAPost = {
    params ["_vehicle", "_group", "_assignment"];
    if (isNil "ALIVE_profileStationary") exitWith { false };
    if ((_assignment select [0, 4]) findIf { _x isNotEqualTo [] } >= 0 || {(_assignment param [5, []]) isNotEqualTo []}) exitWith { false };
    ((_vehicle call ALIVE_fnc_vehicleGetGroupsWithin) findIf {
        _x != _group && {
            private _id = (leader _x) getVariable ["profileID", ""];
            _id != "" && {[ALIVE_profileStationary, _id, false] call ALIVE_fnc_hashGet}
        }
    }) >= 0
};

if(_profileType == "vehicle") then {

    _vehicle = _profile select 2 select 10; //[_profile,"vehicle"] call ALIVE_fnc_hashGet;
    _groupsInVehicle = _vehicle call ALIVE_fnc_vehicleGetGroupsWithin;

    /*
    ["VA TO PVA : %1",_profileID] call ALIVE_fnc_dump;
    ["GROUPS IN VEHICLE: %1",_groupsInVehicle] call ALIVE_fnc_dump;
    */

    {
        _group = _x;
        _leader = leader _group;
        _entityID = _leader getVariable "profileID";

        if !(isnil "_entityID") then {
            _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;

            if !(isnil "_entityProfile") then {
                _entityProfileActive = _entityProfile select 2 select 1; //[_entityProfile,"active"] call ALIVE_fnc_hashGet;

                _assignment = [_vehicle, _group] call ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment;

                if ([_vehicle, _group, _assignment] call _ridesOnAPost) then {
                    // they get out and their group stays spawned; it despawns on its own
                    { if (vehicle _x == _vehicle) then { moveOut _x } } forEach units _group;
                    ["ALiVE profiles - %1 left out of %2: only riding in a pinned group's vehicle", _entityID, _profileID] call ALIVE_fnc_dump;
                } else {
                    _vehicleAssignments = [_profileID,_entityID,_assignment];

                    [_profile, "addVehicleAssignment", _vehicleAssignments] call ALIVE_fnc_profileVehicle;

                    if(_entityProfileActive) then {
                        [_entityProfile,"despawn"] call ALIVE_fnc_profileEntity;
                    };
                };
            };
        };
    } forEach _groupsInVehicle;

} else {

    _units = _profile select 2 select 21; //[_profile,"units"] call ALIVE_fnc_hashGet;
    _group = group (_units select 0);
    _vehiclesUnitsIn = _units call ALIVE_fnc_unitArrayGetVehiclesWithin;

    /*
    ["VA TO PVA : %1",_profileID] call ALIVE_fnc_dump;
    ["UNITS : %1",_units] call ALIVE_fnc_dump;
    ["GROUP : %1",_group] call ALIVE_fnc_dump;
    ["VEHICLES UNITS IN: %1",_vehiclesUnitsIn] call ALIVE_fnc_dump;
    */

    {
        _vehicle = _x;

        if !(isnil "_vehicle") then {
            _vehicleID = _vehicle getVariable ["profileID","none"];

            /*
            if(_vehicleID == "none") then {
                _vehicleID =
            };
            */

            //["V: %1 VID: %2",_vehicle,_vehicleID] call ALIVE_fnc_dump;

            _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
            if !(isnil "_vehicleProfile") then {
                _vehicleProfileActive = _vehicleProfile select 2 select 1; //[_vehicleProfile,"active"] call ALIVE_fnc_hashGet;

                _assignment = [_vehicle, _group] call ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment;

                if ([_vehicle, _group, _assignment] call _ridesOnAPost) then {
                    // left out: the men despawn with their group and come back on foot
                    ["ALiVE profiles - %1 left out of %2: only riding in a pinned group's vehicle", _profileID, _vehicleID] call ALIVE_fnc_dump;
                } else {
                    _vehicleAssignments = [_vehicleID,_profileID,_assignment];

                    [_profile, "addVehicleAssignment", _vehicleAssignments] call ALIVE_fnc_profileEntity;

                    if(_vehicleProfileActive) then {
                        [_vehicleProfile,"despawn"] call ALIVE_fnc_profileVehicle;
                    };
                };
            };
       };
    } forEach _vehiclesUnitsIn;

    // A vehicle the men have all got out of still named this group, as each side clears only its own half.
    // A static gun so left was never despawned and, once virtual, never spawned again for a player (RSS7, 13
    // Nov), so the group is taken off every vehicle it is no longer in.
    private _nowInIDs = _vehiclesUnitsIn apply { _x getVariable ["profileID","none"] };
    {
        private _oldVehicle = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (!isNil "_oldVehicle" && {!(_x in _nowInIDs)}) then {
            private _va = [_oldVehicle,"vehicleAssignments",[]] call ALIVE_fnc_hashGet;
            if (_va isEqualType [] && {count _va > 2}) then { [_va, _profileID] call ALIVE_fnc_hashRem };
            private _inCommand = [_oldVehicle,"entitiesInCommandOf",[]] call ALIVE_fnc_hashGet;
            private _inCargo = [_oldVehicle,"entitiesInCargoOf",[]] call ALIVE_fnc_hashGet;
            private _i = _inCommand find _profileID;
            if (_i >= 0) then { _inCommand deleteAt _i };
            _i = _inCargo find _profileID;
            if (_i >= 0) then { _inCargo deleteAt _i };
        };
    } forEach _wasInIDs;
};