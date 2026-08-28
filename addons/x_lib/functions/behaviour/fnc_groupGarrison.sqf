#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGarrison);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrison
Description:
Garrisons units in defensible structures and static weapons
Parameters:
Group - group
Array - position
Scalar - radius
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Returns:
Examples:
(begin example)
[_group,_position,200,true] call ALIVE_fnc_groupGarrison;
(end)
See Also:
Author:
ARJay, Highhead, Jman
---------------------------------------------------------------------------- */
#define RND(var) random 1 > var

// Garrison occupancy is indexed on the server. Keeping the complete pass on
// that authority makes release and claim operations atomic with respect to
// other garrison groups.
if (!isServer) exitWith {};

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_profileCount",0], ["_profileID",nil], ["_guardPatrolPercentage",50], ["_patrolBehaviour","SAFE"], ["_patrolSpeed","LIMITED"]];

private _units = units _group;
private _unitPercentCount = ((count _units) * _guardPatrolPercentage) / 100;
private _profile = nil;

[_group] call ALiVE_fnc_releaseGarrisonBuildings;

// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
 ["ALIVE_fnc_groupGarrison - _unitPercentCount: %1", _unitPercentCount] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

if !(isNil "_profileID") then {
 _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
 // DEBUG -------------------------------------------------------------------------------------
 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
   ["ALIVE_fnc_groupGarrison - _profile: %1", _profile] call ALiVE_fnc_dump;
 };
 // DEBUG -------------------------------------------------------------------------------------
};

if (count _units < 2) exitwith {};

call ALiVE_fnc_staticDataHandler;

if (!_moveInstantly) then {
    _group lockWP true;
};

private _staticWeapons = nearestObjects [_position, ["StaticWeapon"], _radius];

// Add armed vehicles to list of static weapons to garrison
{
    if ([_x] call ALIVE_fnc_isArmed && { !_onlyProfiled || !isnil { _x getVariable "profileID" } }) then {
        _staticWeapons pushBack _x;
    };
} foreach (nearestObjects [_position, ["Car"], _radius]);

if (count _staticWeapons > 0) then
{
    {
        if (count _units == 0) exitWith {};

        private _weapon = _x;
        private _positionCount = [_weapon] call ALIVE_fnc_vehicleCountEmptyPositions;
        private _unit = _units select 0;

        if (_positionCount > 0) then {
            if (_moveInstantly) then {
                _unit assignAsGunner _weapon;
                _unit moveInGunner _weapon;
            } else {
                _unit assignAsGunner _weapon;
                [_unit] orderGetIn true;
            };

            _units deleteAt 0;
        };
    } forEach _staticWeapons;
};

if (count _units == 0) exitwith {};

// Man CBA AI Building Positions first when present (mission-maker-placed custom positions,
// e.g. trench slots) -- the vanilla buildingPos below does not return them, so prefer these
// explicitly-placed positions over the auto-picked building slots. Consumes only the units it
// fills (mutates _units), so a mission with no CBA positions is unaffected. (#945)
private _movementAssignments = [_units, _position, _radius, _moveInstantly] call ALIVE_fnc_garrisonUnitsOnCBAPositions;

private _fnc_startMovement = {
    params ["_movementGroup", "_assignments"];
    if (_assignments isEqualTo []) exitWith {};

    [_movementGroup, _assignments] spawn {
        params ["_movementGroup", "_assignments"];

        {
            _x params ["_unit", "_destination"];
            if (!isNull _unit && {alive _unit} && {group _unit isEqualTo _movementGroup}) then {
                [_unit, _destination] call ALiVE_fnc_doMoveRemote;
            };
        } forEach _assignments;

        waitUntil {
            sleep 3;

            {
                _x params ["_unit", "_destination", ["_direction", -1]];
                private _stillAssigned = !isNull _unit && {alive _unit} && {group _unit isEqualTo _movementGroup};

                if (!_stillAssigned || {_unit call ALiVE_fnc_unitReadyRemote}) then {
                    if (_stillAssigned) then {
                        if (_direction >= 0) then {
                            _unit setDir _direction;
                        };
                        doStop _unit;
                    };
                    _assignments deleteAt _forEachIndex;
                };
            } forEachReversed _assignments;

            _assignments isEqualTo []
        };
    };
};

if (count _units == 0) exitwith {
    [_group, _movementAssignments] call _fnc_startMovement;
};

private _buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];
if (count _buildings == 0 || _profileCount > 3) then {
	 // DEBUG -------------------------------------------------------------------------------------
	 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
	  ["ALIVE_fnc_groupGarrison - _profileCount: %1, Getting ALIVE_fnc_getEnterableHouses()", _profileCount] call ALiVE_fnc_dump;
	 };
	 // DEBUG -------------------------------------------------------------------------------------
    // append rather than replace: discarding the curated garrison props here
    // left camp and composition structures unmanned whenever the guard count
    // exceeded 3 - the load-spreading intent only needs MORE seats, not fewer
    private _houses = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;
    _buildings = _buildings + (_houses - _buildings);
};

// seat nearest structures first - without this the whitelist sweep (full
// radius) always outranks enterable houses (half radius) and a prop-rich
// objective empties its houses into the props
_buildings = [_buildings, [], { _x distance2D _position }, "ASCEND"] call BIS_fnc_sortBy;

// shared ring geometry for props without engine positions - keep in sync
// with the seat estimators in mil_placement / mil_placement_custom
private _fnc_ringParams = {
    params ["_obj"];
    (boundingBoxReal _obj) params ["_bMin","_bMax"];
    private _bRadius = 0.5 * (((_bMax select 0) - (_bMin select 0)) max ((_bMax select 1) - (_bMin select 1)));
    private _ringRadius = _bRadius + 1;
    [_ringRadius, 2 max (floor ((2 * pi * _ringRadius) / 4)) min 6]
};

// props without engine positions cannot host buildingPatrol.fsm circuits
// (the FSM selectRandoms buildingPos) - patrol only position-bearing props
private _patrolBuildings = _buildings select { !((_x buildingPos -1) isEqualTo []) };
private _patrolWaypointsCleared = false;
if (_patrolBuildings isEqualTo [] && {count _buildings > 0} && {ALiVE_SYS_PROFILE_DEBUG_ON}) then {
    ["ALIVE_fnc_groupGarrison - no patrol-capable props, garrison fully static"] call ALiVE_fnc_dump;
};

// DEBUG -------------------------------------------------------------------------------------
// Men to seat against places to put them. An earlier version of this line reported the guard
// group count under a label that read as men seated, which is how a garrison holding twelve
// props came to look like one seating two men out of ten. Ring-scatter props carry no engine
// positions but do take men, so they are counted the way the seating loop will count them.
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
    private _seatSupply = 0;
    {
        private _engine = count (_x buildingPos -1);
        _seatSupply = _seatSupply + (if (_engine > 0) then {_engine} else {([_x] call _fnc_ringParams) select 1});
    } forEach _buildings;
    ["ALIVE_fnc_groupGarrison - %1 of %2 men still to seat, %3 candidate buildings offering %4 places, radius %5",
     count _units, count (units _group), count _buildings, _seatSupply, _radius] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------



if ((count _buildings == 0) && !(isNil "_profile") && ([_profile,"isCycling"] call ALiVE_fnc_HashGet)) exitwith {

       [_group, _movementAssignments] call _fnc_startMovement;
	
	   private _id = [_profile,"profileID","error"] call ALiVE_fnc_HashGet;
	 	 private _thisGroup = [_profile,"group"] call ALiVE_fnc_HashGet;
	   [_thisGroup] call CBA_fnc_clearWaypoints;
	   [_profile,"isCycling",false] call ALIVE_fnc_hashSet;
	   [_profile,"busy",false] call ALIVE_fnc_hashSet;
	   [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
	   [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
	   // DEBUG -------------------------------------------------------------------------------------
	   if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
      ["ALIVE_fnc_groupGarrison - No enterable buildings found!. Calling CBA_fnc_taskSearchArea on: group: %1, profileID: %2, _radius %3", _group, _id, _radius] call ALiVE_fnc_dump;
	   }; 
	 	 // DEBUG ------------------------------------------------------------------------------------- 
	 	 [_group, [_position, _radius, _radius, 0, false]] call CBA_fnc_taskSearchArea;
};

private _seatDemand = count _units;
private _claimed = 0;
private _claimDenied = 0;

{ // forEach _buildings
	
    if (count _units == 0) exitWith {};

    private _building = _x;
    private _buildingClaimed = [_building, _group] call ALiVE_fnc_claimGarrisonBuilding;

    if (_buildingClaimed) then {
        _claimed = _claimed + 1;

        // GarrisonPositions.hpp names the positions in each class actually worth standing in:
        // three of a cargo tower's sixteen, nine of a cave's fifty odd. Nothing had ever read
        // those lists, so men were placed in whatever slot the model happened to carry,
        // including the ones the curation exists to avoid. The uncurated slots are kept as
        // overflow rather than dropped, so a large group still fits where it used to.
        //
        // The lists are written best first rather than as a plain set - a cargo tower reads
        // [15,12,8] and a cave leads with 53,54 before running up from 4 - so that order is
        // carried through rather than sorted over the top of.
        private _all = _building buildingPos -1;
        private _authored = [ALIVE_garrisonPositions, typeOf _building, []] call ALiVE_fnc_hashGet;
        if (isNil "_authored" || {!(_authored isEqualType [])}) then {_authored = []};

        private _takenIdx = [];
        private _preferred = [];
        private _overflow = [];
        {
            // An index the model no longer carries is skipped rather than trusted. These
            // lists date from 2016 and BIS has renumbered position data underneath them.
            if (_x isEqualType 0 && {_x >= 0} && {_x < count _all} && {!(_x in _takenIdx)}) then {
                private _p = _all select _x;
                if !(_p isEqualTo [0,0,0]) then {
                    _takenIdx pushBack _x;
                    _preferred pushBack _p;
                };
            };
        } forEach _authored;
        {
            // A position that reads as the world origin is not a place to stand; seating a
            // man there puts him at the corner of the map.
            if (!(_forEachIndex in _takenIdx) && {!(_x isEqualTo [0,0,0])}) then {
                _overflow pushBack _x;
            };
        } forEach _all;

        // composition props (tents, camo nets, shelters) carry no engine
        // buildingPos data - synthesise standing positions on a ring just
        // outside the prop's bounding box so the whitelist can seat units.
        // Engine-positioned buildings never reach this branch
        if (_preferred isEqualTo [] && {_overflow isEqualTo []}) then {
            ([_building] call _fnc_ringParams) params ["_ringRadius","_ringCount"];
            for "_i" from 0 to (_ringCount - 1) do {
                private _rp = _building getPos [_ringRadius, _i * (360 / _ringCount)];
                _overflow pushBack [_rp select 0, _rp select 1, 0];
            };
            if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
                ["ALIVE_fnc_groupGarrison - ring-scatter %1 positions around %2 (no buildingPos)", _ringCount, typeOf _building] call ALiVE_fnc_dump;
            };
        };

        // The curated positions keep the order they were written in. Everything else keeps
        // the old treatment, shuffled so repeat visits differ and then highest first.
        [_overflow, true] call CBA_fnc_Shuffle;
        _overflow = [_overflow, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;
        private _preferredCount = count _preferred;
        private _buildingPositions = _preferred + _overflow;
        
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {     
         // A non-empty authored list that matches nothing means the curation has gone stale
         // against the model. Without this the change would fail silently and look identical
         // to having no list at all. The third figure was labelled as the men left to seat
         // but has always been the whole group, so it is named for what it actually is.
         ["ALIVE_fnc_groupgarrison - class: %1, %2 positions, group of %3, %4 of %5 authored positions matched", typeOf _building, count _buildingPositions, count units _group, _preferredCount, count _authored] call ALiVE_fnc_dump;
        };

        { // foreach _buildingPositions

            if (count _units == 0) exitWith {};

            private _unit = _units select 0;
            private _position = _x;

            // A patroller leaves its position for good and nobody refills it, so the quota
            // is taken from the uncurated seats first. Handing it the curated ones emptied
            // the firing ports of a bunker within a minute of the garrison forming. Where a
            // building offers nothing but curated seats its men can still patrol, otherwise
            // a fully curated objective would field none at all.
            private _seatIsCurated = _forEachIndex < _preferredCount;
            private _mayPatrol = !_seatIsCurated || {_overflow isEqualTo []};

            if (_moveInstantly) then {
                _unit setposATL _position;
                _unit setdir ((_unit getRelDir _building)-180);
                dostop _unit;
            } else {
                _movementAssignments pushBack [_unit, _position];
            };
            
            if (_guardPatrolPercentage > 0) then {
            	 if (_mayPatrol && {_unitPercentCount > 0} && {count _patrolBuildings > 0}) then {
                 // Patrol the position-bearing buildings only - ring-scatter
                 // props would feed the FSM empty position lists
                 if (!_patrolWaypointsCleared) then {
                     [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                     _patrolWaypointsCleared = true;
                 };
                 [_group, _unit, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
                 _unitPercentCount = _unitPercentCount -1;
               };
            };
            
            _units deleteAt 0;
        } foreach _buildingPositions;
    } else {
        _claimDenied = _claimDenied + 1;
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
            ["ALIVE_fnc_groupGarrison - _buildingClaimed: %3, count _buildings: %1, _buildings: %2", count _buildings, _buildings, _buildingClaimed] call ALiVE_fnc_dump;
        };
    };
} forEach _buildings;

// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
    // With _moveInstantly false nobody has moved yet - the men are only given somewhere to
    // walk to, and whether they arrive is decided after this function returns.
    private _verb = if (_moveInstantly) then {"seated"} else {"given positions to walk to"};
    ["ALIVE_fnc_groupGarrison - %1 %2 of %3 men across %4 buildings, %5 refused as already claimed by another group",
     _verb, _seatDemand - (count _units), _seatDemand, _claimed, _claimDenied] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

[_group, _movementAssignments] call _fnc_startMovement;

// If any units could not be garrisoned, fall back to ambient movement once.
if (count _units > 0 && {!(isNil "_profile")}) then {
    if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
        ["ALIVE_fnc_groupGarrison - %1 units remain ungarrisoned, calling ALIVE_fnc_ambientMovement", count _units] call ALiVE_fnc_dump;
    };
    [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
    [_profile, [200,"SAFE"]] call ALIVE_fnc_ambientMovement;
};
