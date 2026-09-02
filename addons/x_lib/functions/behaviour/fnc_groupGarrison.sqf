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
Scalar - optional, number of guard groups at this objective
String - optional, profile ID
Scalar - optional, percentage of the group that patrols
String - optional, patrol behaviour
String - optional, patrol speed
String - optional, preferred garrison buildings, Class=idx,idx;...
Boolean - optional, look past the curated props when they cannot seat the group (default true)
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

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_profileCount",0], ["_profileID",nil], ["_guardPatrolPercentage",50], ["_patrolBehaviour","SAFE"], ["_patrolSpeed","LIMITED"], ["_preferredGarrison","",[""]], ["_fillShortfall",true,[false]], ["_preferredIndicesOnly",false,[false]]];

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

// The module's preferred garrison setting arrives as its canonical string and is parsed
// here, so a profile's stored command carries one short string rather than a copy of the
// parsed table. Keys come back folded to lower case and every lookup folds the same way,
// because classnames are case insensitive everywhere else in Arma and the capitalisation
// somebody happens to type must not decide whether their setting works (#1016).
private _preferredHash = [_preferredGarrison] call ALIVE_fnc_resolvePreferredGarrisonPositions;
private _preferredClasses = _preferredHash select 1;

// Exact class matches only. nearestObjects also returns children of a listed class, and the
// written indices belong to the exact model rather than its relatives. A child worth listing
// gets its own entry.
// A list the caller inherited rather than set says which positions in a building class
// are worth standing in. It does not say that those classes are worth walking to. Only a
// module that named them for its own objectives gets the sweep below, which ranks them
// above everything else and exempts them from the claim economy; a garrison the commander
// ordered would otherwise leave the bunkers it was standing beside for a listed hut at the
// far edge of a two hundred metre radius.
private _preferredBuildings = [];
if !((_preferredClasses isEqualTo []) || _preferredIndicesOnly) then {
    // The keys are folded to lower case so the lookup can fold too, but nearestObjects
    // matches its type list case sensitively, so a folded name finds nothing. Config
    // lookup is case insensitive and configName gives back the declared spelling, so the
    // sweep asks with the real classname and the filter still compares folded.
    private _sweepClasses = [];
    {
        private _cfg = configFile >> "CfgVehicles" >> _x;
        if (isClass _cfg) then { _sweepClasses pushBack (configName _cfg) };
    } forEach _preferredClasses;

    if !(_sweepClasses isEqualTo []) then {
        _preferredBuildings = (nearestObjects [_position, _sweepClasses, _radius]) select { (toLower typeOf _x) in _preferredClasses };
    };

};

// The curated sweep is deliberately NOT narrowed by the setting. Cutting a listed class out
// of the filter would also hide that class children from nearestObjects, and buildings that
// are garrisoned today would quietly stop being garrisoned. A listed class is bypassed at
// lookup time instead, where the setting table answers before the curated one, and
// subtracting the objects already booked keeps any one building out of both ranks.
// shared ring geometry for props without engine positions - keep in sync
// with the seat estimators in mil_placement / mil_placement_custom
private _fnc_ringParams = {
    params ["_obj"];
    (boundingBoxReal _obj) params ["_bMin","_bMax"];
    private _bRadius = 0.5 * (((_bMax select 0) - (_bMin select 0)) max ((_bMax select 1) - (_bMin select 1)));
    private _ringRadius = _bRadius + 1;
    [_ringRadius, 2 max (floor ((2 * pi * _ringRadius) / 4)) min 6]
};

// Whether the seating loop below would be allowed to take this building. A building
// another group already owns is refused there, so counting its seats as supply makes
// a group look better provided for than it is. Read only: the bucket is fetched
// without the insert flag, so asking does not claim anything.
private _fnc_claimable = {
    params ["_obj"];
    if (isNil "ALiVE_garrisonBuildingOccupancyIndex") exitWith {true};
    private _bucket = ALiVE_garrisonBuildingOccupancyIndex getOrDefault [hashValue _obj, []];
    private _held = _bucket findIf {(_x select 0) isEqualTo _obj};
    _held < 0 || {((_bucket select _held) select 1) isEqualTo _group}
};

// How many men a set of buildings can actually hold. Ring-scatter props carry no
// engine positions but do take men, so they count the way the seating loop counts
// them rather than as nothing. Buildings held by another group count as nothing,
// because this group cannot have them: with several groups garrisoning one
// objective, every group after the first was reading the whole objective's supply,
// deciding it was well provided for, then being refused building after building and
// handing its leftovers to ambient movement.
private _fnc_seatSupply = {
    params ["_list"];
    private _seats = 0;
    {
        if ([_x] call _fnc_claimable) then {
            private _engine = count (_x buildingPos -1);
            _seats = _seats + (if (_engine > 0) then {_engine} else {([_x] call _fnc_ringParams) select 1});
        };
    } forEach _list;
    _seats
};

private _buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];
_buildings = _buildings - _preferredBuildings;

// Whether the curated props can seat this group at all.
//
// The two triggers below it were the only ones for years, and neither looks at
// how many men need a place. _profileCount is the number of guard GROUPS at the
// objective, not men, and it has to exceed three; the module default of 0.2 tops
// out at two groups and 0.4 at three, so on any default mission that trigger can
// never fire. The other needs the curated sweep to find nothing at all. So a
// group of twelve standing beside one bunker was offered that one bunker, seated
// two or three men in it, and handed the rest to ambient movement, which is why
// they were found wandering in the open next to buildings they could have used.
private _curatedSeats = [_buildings + _preferredBuildings] call _fnc_seatSupply;
private _shortOfSeats = _fillShortfall && {_curatedSeats < count _units};

// Houses found for the shortfall reason are kept apart, because they must rank
// BELOW the curated props rather than being sorted in among them. Sorted together,
// a hut twenty metres away outranks a bunker at eighty and the firing positions
// the curated list exists to fill are left empty.
private _houseRank = [];

// Every house the widening turns up, whichever rank it ends up in. The two paths below
// put them in different lists, and without keeping the set the log calls a house curated
// on the path that merges them into the curated list.
private _houseFound = [];

if (count _buildings == 0 || _profileCount > 3 || _shortOfSeats) then {
	 // DEBUG -------------------------------------------------------------------------------------
	 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
	  ["ALIVE_fnc_groupGarrison - %4: looking beyond the curated props: %1 curated seat(s) for %2 men, guard groups %3", _curatedSeats, count _units, _profileCount, _group] call ALiVE_fnc_dump;
	 };
	 // DEBUG -------------------------------------------------------------------------------------
    private _houses = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;
    private _extra = _houses - _buildings - _preferredBuildings;
    _houseFound = _extra;

    if (count _buildings == 0 || _profileCount > 3) then {
        // append rather than replace: discarding the curated garrison props here
        // left camp and composition structures unmanned whenever the guard count
        // exceeded 3 - the load-spreading intent only needs MORE seats, not fewer
        _buildings = _buildings + _extra;
    } else {
        _houseRank = _extra;
    };
};

// Seat nearest structures first, but only within each rank. One flat sort across the lot
// would let a close curated building outrank a farther listed one, which is the opposite of
// what the setting promises. Without a setting there is only one rank and this is the sort
// that has always run: the whitelist sweep covers the full radius while enterable houses
// cover half, so unsorted a prop-rich objective empties its houses into the props.
_preferredBuildings = [_preferredBuildings, [], { _x distance2D _position }, "ASCEND"] call BIS_fnc_sortBy;
_buildings = [_buildings, [], { _x distance2D _position }, "ASCEND"] call BIS_fnc_sortBy;
_houseRank = [_houseRank, [], { _x distance2D _position }, "ASCEND"] call BIS_fnc_sortBy;
private _preferredTierCount = count _preferredBuildings;

// Ordinary houses last. They are only here because the curated props could not
// seat everybody, so they take the men left over rather than the first ones.
_buildings = _preferredBuildings + _buildings + _houseRank;

// Two passes only when the mission asked for them. With no setting configured this stays
// false and the seating loop below takes exactly the path it takes today, so a mission that
// never touches the attribute sees no change at all.
private _twoPass = !((_preferredClasses isEqualTo []) || _preferredIndicesOnly);

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
    ["ALIVE_fnc_groupGarrison - %8: %1 of %2 men still to seat, %3 candidate buildings offering %4 places; %5 curated seat(s) free to us, %6 house(s) added, radius %7",
     count _units, count (units _group), count _buildings, [_buildings] call _fnc_seatSupply,
     _curatedSeats, count _houseFound, _radius, _group] call ALiVE_fnc_dump;
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

// Second pass state. Only filled when the mission configured the setting; without one
// these stay empty and nothing below them runs.
private _overflowQueues = [];
private _bankedOverflow = 0;
private _authoredPatrolCandidates = [];

{ // forEach _buildings
	
    // Stop claiming once the men still unseated would all fit on overflow already banked;
    // further claims would only fence buildings off from other garrison groups. Buildings
    // the mission listed are exempt, so every one of them is claimed and its written seats
    // filled before this economy applies. Without that exemption the surplus lands on the
    // very slots the setting exists to avoid while listed buildings stand empty.
    if (count _units == 0 || {_twoPass && {_forEachIndex >= _preferredTierCount} && {_bankedOverflow >= count _units}}) exitWith {};

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
        // The module's own setting answers first, on the folded classname. A class it does
        // not name falls back to the curated list, whose keys are exact case by construction.
        private _authored = [_preferredHash, toLower typeOf _building, []] call ALiVE_fnc_hashGet;
        if (isNil "_authored" || {!(_authored isEqualType [])}) then {_authored = []};
        if (_authored isEqualTo []) then {
            _authored = [ALIVE_garrisonPositions, typeOf _building, []] call ALiVE_fnc_hashGet;
            if (isNil "_authored" || {!(_authored isEqualType [])}) then {_authored = []};
        };

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
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
            // A non-empty authored list that matches nothing means the curation has gone stale
            // against the model. Without this the change would fail silently and look identical
            // to having no list at all. The third figure was labelled as the men left to seat
            // but has always been the whole group, so it is named for what it actually is.
            //
            // The group and the rank are named because several garrisons at one objective run
            // at the same time and their lines interleave. Without the group there is no way to
            // tell which garrison a line belongs to, and without the rank no way to tell a house
            // taken because the curated props were full from a house taken instead of them.
            private _rank = if (_building in _houseFound) then {"house"} else {"curated"};
            ["ALIVE_fnc_groupgarrison - %7: class: %1 (%6), %2 positions, group of %3, %4 of %5 authored positions matched", typeOf _building, (count _preferred) + (count _overflow), count units _group, count _preferred, count _authored, _rank, _group] call ALiVE_fnc_dump;
        };

        if (_twoPass) then {
            // Authored seats fill now, in the order written, and never take the patrol quota
            // here. A patroller leaves its seat for good and nobody refills it, and handing the
            // quota to these seats emptied a bunker firing ports within a minute. Men in a
            // building offering nothing but authored seats are remembered instead, and get
            // whatever quota the overflow seats did not use.
            private _authoredOnly = _overflow isEqualTo [];
            {
                if (count _units == 0) exitWith {};
                private _seated = _units deleteAt 0;
                if (_moveInstantly) then {
                    _seated setposATL _x;
                    _seated setdir ((_seated getRelDir _building)-180);
                    dostop _seated;
                } else {
                    _movementAssignments pushBack [_seated, _x];
                };
                if (_authoredOnly) then { _authoredPatrolCandidates pushBack _seated };
            } forEach _preferred;

            // Uncurated seats are banked rather than filled, so the second pass can spread the
            // rest of the group across them instead of packing the first building solid.
            if !(_overflow isEqualTo []) then {
                _overflowQueues pushBack [_building, _overflow];
                _bankedOverflow = _bankedOverflow + count _overflow;
            };
        } else {
            private _preferredCount = count _preferred;
            private _buildingPositions = _preferred + _overflow;
        
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
        };
    } else {
        _claimDenied = _claimDenied + 1;
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
            ["ALIVE_fnc_groupGarrison - %4: %1 already claimed by another group, %2 of %3 candidates tried", typeOf _building, _forEachIndex + 1, count _buildings, _group] call ALiVE_fnc_dump;
        };
    };
} forEach _buildings;

// Second pass. Whoever is left is dealt one seat per building per cycle, in the same
// listed-then-curated, nearest-first order the claims were made in. Dealing from the far
// end would top up the least preferred buildings first whenever the surplus is small.
// Overflow seats were always the patrol pool, so these men are patrol eligible as before.
while {_twoPass && {count _units > 0} && {!(_overflowQueues isEqualTo [])}} do {
    {
        if (count _units == 0) exitWith {};
        _x params ["_queueBuilding", "_queuePositions"];
        private _seated = _units deleteAt 0;
        private _seatPos = _queuePositions deleteAt 0;

        if (_moveInstantly) then {
            _seated setposATL _seatPos;
            _seated setdir ((_seated getRelDir _queueBuilding)-180);
            dostop _seated;
        } else {
            _movementAssignments pushBack [_seated, _seatPos];
        };

        if (_guardPatrolPercentage > 0 && {_unitPercentCount > 0} && {count _patrolBuildings > 0}) then {
            if (!_patrolWaypointsCleared) then {
                [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                _patrolWaypointsCleared = true;
            };
            [_group, _seated, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
            _unitPercentCount = _unitPercentCount - 1;
        };
    } forEach _overflowQueues;
    _overflowQueues = _overflowQueues select { !((_x select 1) isEqualTo []) };
};

// Whatever quota the overflow seats did not use goes last to men in authored-only
// buildings, the same men who are allowed to patrol today when their building offers
// nothing else.
if (_twoPass && {_guardPatrolPercentage > 0} && {count _patrolBuildings > 0}) then {
    {
        if (_unitPercentCount <= 0) exitWith {};
        if (!_patrolWaypointsCleared) then {
            [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
            _patrolWaypointsCleared = true;
        };
        [_group, _x, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
        _unitPercentCount = _unitPercentCount - 1;
    } forEach _authoredPatrolCandidates;
};
// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
    // With _moveInstantly false nobody has moved yet - the men are only given somewhere to
    // walk to, and whether they arrive is decided after this function returns.
    private _verb = if (_moveInstantly) then {"seated"} else {"given positions to walk to"};
    ["ALIVE_fnc_groupGarrison - %6: %1 %2 of %3 men across %4 buildings, %5 refused as already claimed by another group",
     _verb, _seatDemand - (count _units), _seatDemand, _claimed, _claimDenied, _group] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

[_group, _movementAssignments] call _fnc_startMovement;

// If any units could not be garrisoned, fall back to ambient movement once.
if (count _units > 0 && {!(isNil "_profile")}) then {
    if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
        ["ALIVE_fnc_groupGarrison - %2: %1 units remain ungarrisoned, calling ALIVE_fnc_ambientMovement", count _units, _group] call ALiVE_fnc_dump;
    };
    [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
    [_profile, [200,"SAFE"]] call ALIVE_fnc_ambientMovement;
};
