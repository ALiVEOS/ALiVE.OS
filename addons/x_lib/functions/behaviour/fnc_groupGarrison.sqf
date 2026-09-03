#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGarrison);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrison
Description:
Garrisons units in defensible structures and static weapons
Parameters:
Group - group
Array - centre of the area to search. For a placed garrison this is the objective,
        not where the group stands.
Scalar - how far from that centre to search
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Scalar - optional, number of guard groups at this objective
String - optional, profile ID
Scalar - optional, percentage of the group that patrols
String - optional, patrol behaviour
String - optional, patrol speed
String - optional, preferred garrison buildings, Class=idx,idx;...
Boolean - optional, look past the curated props when they cannot seat the group (default true)
Boolean - optional, the list was inherited rather than set here, so it supplies positions only
Array - optional, where the group stands. Candidates are handed out nearest to it, and the
        house fallback and patrol circuits are drawn around it. Defaults to the search centre.
Scalar - optional, how far the fallback and the patrol circuits reach from the group.
        Defaults to the search radius, which is what every caller had before.

The most men one building may take is NOT a parameter. It is read off the placement
modules by ALIVE_fnc_garrisonOccupancyLimit, so no caller has to know about it. Each
group's own figure is raised above the setting where its share of the free buildings
could not otherwise seat it, and a caller that passes no guard-group count is assumed
to be sharing the objective with one other group. Nothing here can leave a man outside
who would have had a place without the setting.

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

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_profileCount",0], ["_profileID",nil], ["_guardPatrolPercentage",50], ["_patrolBehaviour","SAFE"], ["_patrolSpeed","LIMITED"], ["_preferredGarrison","",[""]], ["_fillShortfall",true,[false]], ["_preferredIndicesOnly",false,[false]], ["_groupPosition",[],[[]]], ["_fallbackRadius",0,[0]]];

// Two anchors, kept apart on purpose. The SEARCH, which decides what candidates exist
// at all, is centred on _position and reaches _radius: for a placed garrison that is the
// objective and its size, so a group scattered to the rim of a large objective still sees
// the buildings in the middle of it. The ORDER, which decides which of those this group
// takes, and the FALLBACK, where it looks once they run out, are anchored on
// _groupPosition and reach _fallbackRadius. Ordered from the objective centre instead,
// every group would walk to the same buildings in the same order, the middle would fill
// while the edges stood empty, and the scatter that spreads guards across an objective
// would count for nothing. A caller that gives neither is searching from where the group
// stands, which is what every caller did before these existed (#1016).
if (_groupPosition isEqualTo []) then { _groupPosition = _position };
if (_fallbackRadius <= 0) then { _fallbackRadius = _radius };

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

// The sweep covers the objective, but the guns are taken nearest the group, the same rule
// the buildings follow below. There is no claim economy for weapons and a man is moved
// straight into one, so an unsorted list swept from the objective centre would put the
// first man of a group at the east rim into a gun at the west rim.
//
// Guns beyond the group's own reach are dropped outright, with no fallback to the wider
// set. A fallback would restore exactly the teleport this exists to stop, and unlike the
// buildings there is nothing gentler it could do: the man is moved into the gunner seat
// at once. A group with no gun near it simply mans none and takes buildings instead,
// which is what it did before the search widened.
//
// Sorting also merges the vehicles appended above back into the nearest-first order the
// sweep had before the pushBack broke it.
_staticWeapons = [_staticWeapons, [], { _x distance2D _groupPosition }, "ASCEND"] call BIS_fnc_sortBy;
_staticWeapons = _staticWeapons select { (_x distance2D _groupPosition) <= _fallbackRadius };

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
private _movementAssignments = [_units, _position, _radius, _moveInstantly, _groupPosition] call ALIVE_fnc_garrisonUnitsOnCBAPositions;

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

// Classes no garrison may use, from every placement module and from the mission's own
// init.sqf list. Worked out once for the mission and kept, so the ordinary case of no
// blacklist at all costs one variable read. Everything below tests the flag rather than
// the array, because filtering asks for the classname of every object a sweep returned
// and that is real work to do for a filter that can never reject anything.
private _blacklist = call ALIVE_fnc_garrisonBuildingBlacklist;
private _excluding = !(_blacklist isEqualTo []);

// The most men any one building may take, from the placement modules, worked out once
// for the mission the way the blacklist is. Read here rather than passed, so no caller
// anywhere has to know about it (#1016).
private _cap = call ALIVE_fnc_garrisonOccupancyLimit;
private _capped = _cap > 0;
// The buildings the blacklist withheld at this objective, held as objects rather
// than counted as they are found. The curated sweep and the house sweep overlap,
// and the curated one is filtered before the subtraction that would have removed
// the duplicate, so counting each sweep separately reports some buildings twice.
private _excludedSet = [];

// Folded in at source rather than filtered after the sweep, so a class named in both
// settings is never swept for. The blacklist wins over the preferred list: it is the
// stronger statement of the two and the only one that can say "never".
// How many classes the blacklist took out of the listed set, kept apart from the
// count of buildings withheld below: one is a setting the author wrote, the other
// is what stands at this objective, and adding them gives a figure that is neither.
private _excludedClasses = 0;
if (_excluding) then {
    private _before = count _preferredClasses;
    _preferredClasses = _preferredClasses select { !(_x in _blacklist) };
    _excludedClasses = _before - (count _preferredClasses);
};

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

// How many OTHER groups already hold buildings among a candidate list. Used only to
// work out how many groups are still to come, so a limit does not let the first group
// fence off buildings the rest of the objective's guards still need. Read only, the
// same bucket lookup as above. This group's own claims were released before it got
// here, so they never count.
private _fnc_otherHolders = {
    params ["_list"];
    if (isNil "ALiVE_garrisonBuildingOccupancyIndex") exitWith {0};
    private _holders = [];
    {
        private _obj = _x;
        private _bucket = ALiVE_garrisonBuildingOccupancyIndex getOrDefault [hashValue _obj, []];
        private _held = _bucket findIf {(_x select 0) isEqualTo _obj};
        if (_held >= 0) then {
            private _owner = (_bucket select _held) select 1;
            if !(_owner isEqualTo _group) then { _holders pushBackUnique _owner };
        };
    } forEach _list;
    count _holders
};

// How many men a set of buildings can actually hold. Ring-scatter props carry no
// engine positions but do take men, so they count the way the seating loop counts
// them rather than as nothing. Buildings held by another group count as nothing,
// because this group cannot have them: with several groups garrisoning one
// objective, every group after the first was reading the whole objective's supply,
// deciding it was well provided for, then being refused building after building and
// handing its leftovers to ambient movement.
private _fnc_seatSupply = {
    params ["_list", ["_perBuilding", 0]];
    private _seats = 0;
    {
        private _obj = _x;
        if ([_obj] call _fnc_claimable) then {
            // Only the positions the seating loop will actually offer. It throws away any
            // that read as the world origin, because seating a man there puts him at the
            // corner of the map, and counting them here made a garrison look better
            // provided for than it was: the supply said there was room, the loop then
            // found there was not, and the men left over went to ambient movement.
            private _engine = count ((_obj buildingPos -1) select {!(_x isEqualTo [0,0,0])});
            private _places = if (_engine > 0) then {_engine} else {([_obj] call _fnc_ringParams) select 1};
            // Only what the limit will let this group take out of the building. Left
            // uncapped, a group told it had plenty would never sweep for houses and
            // would then hit the limit with nowhere left to go.
            if (_perBuilding > 0) then { _places = _places min _perBuilding };
            _seats = _seats + _places;
        };
    } forEach _list;
    _seats
};

private _buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];
if (_excluding) then {
    private _kept = _buildings select { !((toLower typeOf _x) in _blacklist) };
    { _excludedSet pushBackUnique _x } forEach (_buildings - _kept);
    _buildings = _kept;
};
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
private _curatedSeats = [_buildings + _preferredBuildings, _cap] call _fnc_seatSupply;
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

// Named, because the second round below only runs when this one did not: a garrison that
// already fetched the houses gains nothing from fetching them again.
private _lookedBeyond = count _buildings == 0 || _profileCount > 3 || _shortOfSeats;

if (_lookedBeyond) then {
	 // DEBUG -------------------------------------------------------------------------------------
	 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
	  ["ALIVE_fnc_groupGarrison - %4: looking beyond the curated props: %1 curated seat(s) for %2 men, guard groups %3", _curatedSeats, count _units, _profileCount, _group] call ALiVE_fnc_dump;
	 };
	 // DEBUG -------------------------------------------------------------------------------------
    // Houses are the safety net for men the curated props could not seat, so they are
    // swept around the men rather than around the objective. Swept from the centre at half
    // the objective, a group at the rim would be offered houses hundreds of metres away
    // while the shed beside it went unlisted. The radius is the caller's own guard radius,
    // not the objective-sized search, so this sweep costs what it always cost.
    private _houses = [_groupPosition, floor(_fallbackRadius/2)] call ALIVE_fnc_getEnterableHouses;
    // Filtered after the subtraction so the houses this rank offers are the ones that
    // survive it. A building the curated sweep already withheld can still turn up
    // here, which is why the count above is a set rather than a running total.
    private _extra = _houses - _buildings - _preferredBuildings;
    if (_excluding) then {
        private _kept = _extra select { !((toLower typeOf _x) in _blacklist) };
        { _excludedSet pushBackUnique _x } forEach (_extra - _kept);
        _extra = _kept;
    };
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
_preferredBuildings = [_preferredBuildings, [], { _x distance2D _groupPosition }, "ASCEND"] call BIS_fnc_sortBy;
_buildings = [_buildings, [], { _x distance2D _groupPosition }, "ASCEND"] call BIS_fnc_sortBy;
_houseRank = [_houseRank, [], { _x distance2D _groupPosition }, "ASCEND"] call BIS_fnc_sortBy;
private _preferredTierCount = count _preferredBuildings;

// Ordinary houses last. They are only here because the curated props could not
// seat everybody, so they take the men left over rather than the first ones.
_buildings = _preferredBuildings + _buildings + _houseRank;

// The limit, bounded by this group's share of the objective.
//
// Buildings are claimed whole and for good: the first man a group seats in one takes
// the entire building, and nothing hands it back while the group lives. So a limit
// that made every group claim ceil(men / limit) buildings would let the early groups
// fence off buildings they barely use, and the groups behind them would find every
// building refused and end up in the open. That is the same fault the objective-wide
// search was written to cure, so the limit must not reintroduce it (#1016).
//
// Rather than stopping a group when it has claimed its share, its own limit is RAISED
// until its share can seat it. Where buildings are plentiful the figure is the limit
// as written. Where they are scarce it climbs back towards filling each building, which
// is exactly today's behaviour, so the limit can never leave a man outside who would
// have had a seat without it. Yielding by arithmetic rather than by a stop also means
// there is no case left where the group has run out of buildings and still has men.
//
// The expected share of groups counts those still to come, not those already served:
// the first of five groups divides by five, the last divides by one and may take what
// is left. A caller that gives no guard count at all (the commander, reserves,
// roadblocks) assumes two, so it leaves at least half of what it found for whoever
// follows rather than assuming it is alone.
private _groupCap = _cap;
private _freeCount = 0;
private _othersHolding = 0;
private _expected = 1;
if (_capped) then {
    _freeCount = count (_buildings select { [_x] call _fnc_claimable });
    _othersHolding = [_buildings] call _fnc_otherHolders;
    _expected = if (_profileCount > 1 && {_othersHolding < _profileCount}) then {_profileCount - _othersHolding} else {2};
    private _share = 1 max floor (_freeCount / _expected);
    _groupCap = _cap max ceil ((count _units) / _share);
    if (_groupCap > _cap && {ALiVE_SYS_PROFILE_DEBUG_ON}) then {
        ["ALIVE_fnc_groupGarrison - %1: limit raised from %2 to %3 for this group: %4 free building(s) to share among %5 group(s) still expected (%6 guard group(s), %7 other group(s) already holding buildings here), share %8",
         _group, _cap, _groupCap, _freeCount, _expected, _profileCount, _othersHolding, _share] call ALiVE_fnc_dump;
    };
};

// Two passes only when the mission asked for them. With no setting configured this stays
// false and the seating loop below takes exactly the path it takes today, so a mission that
// never touches the attribute sees no change at all.
private _twoPass = !((_preferredClasses isEqualTo []) || _preferredIndicesOnly);

// Named for the log. Three states reach this point and two of them leave the same
// variables behind, so the log has to say which one happened outright. The inherited
// case prints the tier count rather than implying it: a working guard swept no listed
// buildings, and a broken one would say so here instead of looking identical to a
// garrison that simply had no list. The inheritance flag is tested before the empty
// test, because a pooled list that resolved to nothing is still the inherited path.
private _preferredState = call {
    if (_preferredIndicesOnly && {_preferredClasses isEqualTo []}) exitWith {
        "list inherited, but the mission pool held nothing"
    };
    if (_preferredIndicesOnly) exitWith {
        format ["list inherited: %1 class(es), positions borrowed, %2 listed building(s) swept for it",
                count _preferredClasses, _preferredTierCount]
    };
    if (_preferredClasses isEqualTo [] && {_excludedClasses > 0}) exitWith {
        format ["a list was set but the blacklist excluded all %1 of its classes", _excludedClasses]
    };
    if (_preferredClasses isEqualTo []) exitWith { "no preferred list" };
    format ["list set here: %1 class(es), %2 listed building(s) swept",
            count _preferredClasses, _preferredTierCount]
};

// props without engine positions cannot host buildingPatrol.fsm circuits
// (the FSM selectRandoms buildingPos) - patrol only position-bearing props
// Patrol circuits are a destination, not a search, so they are kept near where the group
// started. Left as the whole objective a guard would walk the length of a large airfield
// between two buildings and spend the mission in transit.
//
// The reach is measured from where the group stood before seating, not from the seat it
// ends up in, so a man seated far across the objective can still draw a circuit near the
// group's old spot. Accepted rather than fixed: the seats are handed out nearest the
// group anyway, so the two are usually the same place, and the alternative is rebuilding
// this list after every claim. When nothing at all is close enough the full set is used,
// which is the behaviour every garrison had before the search widened.
private _patrolBuildings = _buildings select { !((_x buildingPos -1) isEqualTo []) };
private _patrolInReach = _patrolBuildings select { (_x distance2D _groupPosition) <= _fallbackRadius };
if !(_patrolInReach isEqualTo []) then { _patrolBuildings = _patrolInReach };
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
    // Named, not just counted. A number on its own cannot answer the only question
    // worth asking of it, which is whether the class the author meant to exclude is
    // the one that actually got refused.
    private _excludedNote = if (_excludedSet isEqualTo []) then { "0 buildings withheld by the blacklist" } else {
        private _names = [];
        { _names pushBackUnique (typeOf _x) } forEach _excludedSet;
        format ["%1 building(s) withheld by the blacklist (%2)", count _excludedSet, _names joinString ", "]
    };

    // The places figure is asked for uncapped so it stays comparable between a run with
    // a limit and one without; the limit in force is named separately.
    private _limitState = if (_capped) then { format ["limit %1 per building", _groupCap] } else { "no occupancy limit" };

    ["ALIVE_fnc_groupGarrison - %8: %1 of %2 men still to seat, %3 candidate buildings offering %4 places; %5 curated seat(s) free to us, %6 house(s) added, %10, radius %7; %9; %11",
     count _units, count (units _group), count _buildings, [_buildings] call _fnc_seatSupply,
     _curatedSeats, count _houseFound, _radius, _group, _preferredState, _excludedNote, _limitState] call ALiVE_fnc_dump;
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
      ["ALIVE_fnc_groupGarrison - No enterable buildings found!. Calling CBA_fnc_taskSearchArea on: group: %1, profileID: %2, searched %3 m from the objective, tasking %4 m around the men", _group, _id, round _radius, round _fallbackRadius] call ALiVE_fnc_dump;
	   }; 
	 	 // DEBUG ------------------------------------------------------------------------------------- 
	 	 // The area to search on foot is drawn around the men at the guard radius, which is
	 	 // what this call received before the search widened to the objective.
	 	 [_group, [_groupPosition, _fallbackRadius, _fallbackRadius, 0, false]] call CBA_fnc_taskSearchArea;
};

private _seatDemand = count _units;
private _claimed = 0;
private _claimDenied = 0;

// Second pass state. Only filled when the mission configured the setting; without one
// these stay empty and nothing below them runs.
private _overflowQueues = [];
private _bankedOverflow = 0;
private _authoredPatrolCandidates = [];

// How many men ended up in each building this group claimed, in claim order, so the log
// can say so outright rather than leaving it to be reconstructed from the class lines.
// Filled whichever seating branch runs.
private _occupancy = [];
// Men who got the patrol quota from where they stood rather than from a seat.
private _patrolFromStart = 0;

// One round of claims over one list of candidates. This is a block rather than a bare
// loop so it can run a second time, over houses fetched after the first round, without a
// second copy of the seating rules. The forEach is the whole block, so the early exit
// inside it still ends the walk exactly as it did.
//
// _twoPass arrives as a parameter because a second round has no listed tier of its own:
// with it false the exit asks only whether men remain, and every building seats directly
// rather than banking overflow the drain below has already dealt out.
private _fnc_claimRound = {
    params ["_candidates", "_twoPass"];

{ // forEach _candidates
	
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

        // What this building may take. A class the MISSION named carries the positions the
        // mission wrote for it whatever the limit: naming three ports in a bunker is itself
        // a statement about how many men belong there, and the setting already promises
        // those positions fill first and in that order. _preferredClasses holds only the
        // mission's own list, never the built-in curated keys, so a building with a built-in
        // list stays under the limit. A listed class whose indices matched nothing falls
        // through to the limit rather than to a budget of nothing.
        private _listed = (toLower typeOf _building) in _preferredClasses;
        private _budget = if (_capped) then {
            if (_listed && {count _preferred > 0}) then { count _preferred } else { _groupCap }
        } else {
            (count _preferred) + (count _overflow)
        };
        private _occIdx = count _occupancy;
        _occupancy pushBack [_building, 0];
        private _seatedHere = 0;
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
            // Where the seats came from, which is the half the rank cannot show. A
            // building can be curated and still be seated on positions the mission named.
            private _from = if (_authored isEqualTo []) then {"no named positions"} else {
                if (_preferredTierCount > 0 && {_building in _preferredBuildings}) then {"listed tier"} else {
                    if ((toLower typeOf _building) in _preferredClasses) then {"positions from the setting"} else {"built-in positions"}
                }
            };
            private _budgetNote = if (_capped) then {
                format [", seating up to %1%2", _budget, if (_listed && {count _preferred > 0}) then {" (the positions listed)"} else {""}]
            } else { "" };
            ["ALIVE_fnc_groupgarrison - %7: class: %1 (%6, %8), %2 positions, group of %3, %4 of %5 authored positions matched%9", typeOf _building, (count _preferred) + (count _overflow), count units _group, count _preferred, count _authored, _rank, _group, _from, _budgetNote] call ALiVE_fnc_dump;
        };

        if (_twoPass) then {
            // Authored seats fill now, in the order written, and never take the patrol quota
            // here. A patroller leaves its seat for good and nobody refills it, and handing the
            // quota to these seats emptied a bunker firing ports within a minute. Men in a
            // building offering nothing but authored seats are remembered instead, and get
            // whatever quota the overflow seats did not use.
            private _authoredOnly = _overflow isEqualTo [];
            {
                if (count _units == 0 || {_seatedHere >= _budget}) exitWith {};
                private _seated = _units deleteAt 0;
                if (_moveInstantly) then {
                    _seated setposATL _x;
                    _seated setdir ((_seated getRelDir _building)-180);
                    dostop _seated;
                } else {
                    _movementAssignments pushBack [_seated, _x];
                };
                _seatedHere = _seatedHere + 1;
                // With a limit in force a man in a curated seat may still patrol, because
                // the budget can stop the overflow seats being reached at all and a fully
                // curated objective would otherwise field no patrols whatsoever.
                if (_authoredOnly || _capped) then { _authoredPatrolCandidates pushBack _seated };
            } forEach _preferred;

            (_occupancy select _occIdx) set [1, _seatedHere];

            // Uncurated seats are banked rather than filled, so the second pass can spread the
            // rest of the group across them instead of packing the first building solid.
            //
            // Under a limit the authored seats the budget did not reach head the banked list,
            // so the drain uses the positions the mission named before any ordinary one, and
            // only the budget's worth counts towards the claim economy below. Banking the whole
            // building's worth is what let one house satisfy the early stop on its own and hand
            // the round-robin a single building to spread twelve men across (#1016).
            private _leftover = if (_capped) then { (_preferred select [_seatedHere]) + _overflow } else { _overflow };
            if !(_leftover isEqualTo []) then {
                _overflowQueues pushBack [_building, _leftover, _occIdx, (count _preferred) - _seatedHere, _budget];
                _bankedOverflow = _bankedOverflow + (if (_capped) then { ((_budget - _seatedHere) max 0) min (count _leftover) } else { count _overflow });
            };
        } else {
            private _preferredCount = count _preferred;
            private _buildingPositions = _preferred + _overflow;

            // Only the budget's worth is offered. The men above it are NOT banked as
            // unseated: leaving them in _units keeps the candidate walk going to the next
            // building, which is what stops one rich building absorbing a whole group
            // before any other is tried (#1016). A prefix, so the curated test below still
            // holds.
            private _offered = if (_capped) then { _buildingPositions select [0, _budget] } else { _buildingPositions };

            { // foreach _offered

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
                         // The roadblock callers garrison a group that has no profile, so
                         // there is nothing to clear waypoints on. Asking anyway threw.
                         if !(isNil "_profile") then {
                             [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                         };
                         _patrolWaypointsCleared = true;
                     };
                     [_group, _unit, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
                     _unitPercentCount = _unitPercentCount -1;
                   };
                };
            
                // A man the budget kept out of an overflow seat can still be given the
                // quota later from where he stands, so he is remembered rather than lost.
                if (_capped && {!_mayPatrol}) then { _authoredPatrolCandidates pushBack _unit };

                _units deleteAt 0;
                _seatedHere = _seatedHere + 1;
            } foreach _offered;

            (_occupancy select _occIdx) set [1, _seatedHere];

            // What the budget left behind, for the relaxation to fall back on if every
            // building this group can reach ends up at its limit.
            if (_capped) then {
                private _leftover = _buildingPositions select [_seatedHere];
                if !(_leftover isEqualTo []) then {
                    _overflowQueues pushBack [_building, _leftover, _occIdx, (_preferredCount - _seatedHere) max 0, _budget];
                };
            };
        };
    } else {
        _claimDenied = _claimDenied + 1;
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
            ["ALIVE_fnc_groupGarrison - %4: %1 already claimed by another group, %2 of %3 candidates tried", typeOf _building, _forEachIndex + 1, count _candidates, _group] call ALiVE_fnc_dump;
        };
    };
} forEach _candidates;
};

// Deals whoever is left one seat per building per cycle, in the same listed-then-curated,
// nearest-first order the claims were made in. Dealing from the far end would top up the
// least preferred buildings first whenever the surplus is small.
//
// Called twice under a limit. The first pass respects each building's budget, so the men
// spread across the buildings the group holds without any going over. The second is the
// relaxation, called only when every building is at its budget and men are still standing,
// and it ignores the budget so the last men take real places rather than being sent to
// ambient movement. Without a limit the first call behaves exactly as the loop that stood
// here before: nothing has a budget to respect and every entry is dealable.
private _fnc_drain = {
    params ["_respectBudget"];
    private _dealt = 0;
    private _cycles = 0;

    private _fnc_dealable = {
        _overflowQueues select {
            !((_x select 1) isEqualTo []) && {!_respectBudget || {((_occupancy select (_x select 2)) select 1) < (_x select 4)}}
        }
    };

    private _dealable = call _fnc_dealable;
    while {count _units > 0 && {!(_dealable isEqualTo [])}} do {
        {
            if (count _units == 0) exitWith {};
            private _entry = _x;
            _entry params ["_queueBuilding", "_queuePositions", "_qOccIdx", "_curatedLeft"];
            private _seated = _units deleteAt 0;
            private _seatPos = _queuePositions deleteAt 0;

            if (_moveInstantly) then {
                _seated setposATL _seatPos;
                _seated setdir ((_seated getRelDir _queueBuilding)-180);
                dostop _seated;
            } else {
                _movementAssignments pushBack [_seated, _seatPos];
            };

            (_occupancy select _qOccIdx) set [1, ((_occupancy select _qOccIdx) select 1) + 1];
            _dealt = _dealt + 1;

            // Authored seats the budget did not reach head the queue, and they keep the
            // exemption they have in the first pass: a patroller abandons his position for
            // good, and the mission named those positions because it wanted them held.
            private _mayPatrol = _curatedLeft <= 0;
            if (_curatedLeft > 0) then { _entry set [3, _curatedLeft - 1] };

            if (_mayPatrol && {_guardPatrolPercentage > 0} && {_unitPercentCount > 0} && {count _patrolBuildings > 0}) then {
                if (!_patrolWaypointsCleared) then {
                    if !(isNil "_profile") then {
                        [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                    };
                    _patrolWaypointsCleared = true;
                };
                [_group, _seated, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
                _unitPercentCount = _unitPercentCount - 1;
            };
        } forEach _dealable;
        _cycles = _cycles + 1;
        _dealable = call _fnc_dealable;
    };

    _overflowQueues = _overflowQueues select { !((_x select 1) isEqualTo []) };
    [_dealt, _cycles]
};

[_buildings, _twoPass] call _fnc_claimRound;

// Second pass. Overflow seats were always the patrol pool, so these men are patrol
// eligible as before. Only the two-pass path banks anything: without a list every claimed
// building was already filled to its budget as it was claimed, so a budget-respecting
// deal would find nothing left to give out.
if (_twoPass) then {
    ([_capped] call _fnc_drain) params ["_dealt", "_cycles"];
    if (ALiVE_SYS_PROFILE_DEBUG_ON && {_dealt > 0}) then {
        ["ALIVE_fnc_groupGarrison - %1: dealt %2 men round-robin across %3 building(s) with places left in %4 cycle(s), %5 still to seat", _group, _dealt, count _overflowQueues, _cycles, count _units] call ALiVE_fnc_dump;
    };
};

// A second look, on the evidence of men still standing. The supply was counted before
// the first claim was made, and several groups garrison one objective at once from their
// own threads, so a group that read the objective as well provided for can find every
// building taken by the time its turn comes. Having never thought itself short it never
// looked for houses, and its leftovers went to ambient movement. They are fetched now
// instead, and walked after everything already tried. A caller that was told not to look
// past the curated props still does not, and a garrison that already looked gains nothing
// from looking twice.
//
// This bounds the race to one retry rather than removing it: two groups arriving here
// together can still both sweep the same houses. The refusal count is logged so a
// residual collision reads as one in the RPT rather than as the fix having failed.
if (count _units > 0 && {_fillShortfall} && {!_lookedBeyond}) then {
    private _claimedBefore = _claimed;
    private _deniedBefore = _claimDenied;
    private _stillToSeat = count _units;

    // Around the men at the guard radius, for the reason given at the first house sweep.
    private _swept = [_groupPosition, floor(_fallbackRadius/2)] call ALIVE_fnc_getEnterableHouses;
    private _evidence = _swept - _buildings;
    if (_excluding) then {
        _evidence = _evidence select { !((toLower typeOf _x) in _blacklist) };
    };
    _evidence = [_evidence, [], { _x distance2D _groupPosition }, "ASCEND"] call BIS_fnc_sortBy;
    _houseFound = _houseFound + _evidence;

    // A new array rather than the old one grown, so patrol circuits already handed out
    // keep the list they were given.
    _patrolBuildings = _patrolBuildings + (_evidence select { !((_x buildingPos -1) isEqualTo []) });
    _patrolBuildings = _patrolBuildings arrayIntersect _patrolBuildings;

    // Round two has no listed tier of its own, so it seats directly rather than banking
    // overflow the drain above has already finished with.
    [_evidence, false] call _fnc_claimRound;

    if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
        ["ALIVE_fnc_groupGarrison - %7: second look: %1 men still to seat after %2 refusal(s) against an estimate of %3 seat(s), %4 house(s) fetched, %5 claimed, %6 still standing",
         _stillToSeat, _deniedBefore, _curatedSeats, count _evidence,
         _claimed - _claimedBefore, count _units, _group] call ALiVE_fnc_dump;
    };
};



// Under a limit, whoever is still standing after every building has been tried.
//
// This is what makes the limit a preference rather than a fence, and it is the whole
// reason the limit is safe to ship: a man reaches ambient movement below only when every
// place in every building this group holds is occupied, which is the same condition as
// before the limit existed.
if (_capped && {count _units > 0}) then {

    // The patrol quota first. A patroller never needed a seat: today he is given one and
    // then walks away from it for good, so spending the quota on men who have no seat
    // recovers waste rather than costing anyone a place.
    if (_guardPatrolPercentage > 0 && {_unitPercentCount > 0} && {count _patrolBuildings > 0}) then {
        while {_unitPercentCount > 0 && {count _units > 0}} do {
            private _walker = _units deleteAt 0;
            if (!_patrolWaypointsCleared) then {
                if !(isNil "_profile") then {
                    [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                };
                _patrolWaypointsCleared = true;
            };
            [_group, _walker, _patrolBuildings, ALiVE_SYS_PROFILE_DEBUG_ON, _patrolBehaviour, _patrolSpeed] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
            _unitPercentCount = _unitPercentCount - 1;
            _patrolFromStart = _patrolFromStart + 1;
        };
        if (ALiVE_SYS_PROFILE_DEBUG_ON && {_patrolFromStart > 0}) then {
            ["ALIVE_fnc_groupGarrison - %1: %2 man/men left over given the unused patrol quota from where they stood, %3 still to seat", _group, _patrolFromStart, count _units] call ALiVE_fnc_dump;
        };
    };

    // Then the limit gives way. Every building held is at its budget and men are still
    // standing, so the budget is dropped and the same round-robin deals them into the
    // places left over, one per building per cycle so no single building takes them all.
    if (count _units > 0 && {(_overflowQueues findIf {!((_x select 1) isEqualTo [])}) > -1}) then {
        private _left = 0;
        { _left = _left + count (_x select 1) } forEach _overflowQueues;
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
            ["ALIVE_fnc_groupGarrison - %1: limit of %2 per building reached in all %3 building(s) held, %4 still to seat, dealing them into the %5 place(s) left over", _group, _groupCap, count _occupancy, count _units, _left] call ALiVE_fnc_dump;
        };
        [false] call _fnc_drain;
    };
};

// Whatever quota the overflow seats did not use goes last to men in authored-only
// buildings, the same men who are allowed to patrol today when their building offers
// nothing else. With a limit in force the pool also holds men the budget kept out of an
// overflow seat, who would otherwise never be considered.
if ((_twoPass || _capped) && {_guardPatrolPercentage > 0} && {count _patrolBuildings > 0}) then {
    {
        if (_unitPercentCount <= 0) exitWith {};
        if (!_patrolWaypointsCleared) then {
            if !(isNil "_profile") then {
                [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
            };
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
    // How the men actually landed, building by building, in claim order. Reconstructing
    // this from the class lines by hand is how the packing was found in the first place.
    private _perBuilding = if (_occupancy isEqualTo []) then {"none"} else {(_occupancy apply {_x select 1}) joinString "/"};
    private _limitNote = if (_capped) then {_groupCap} else {"none"};
    private _patrolNote = if (_patrolFromStart > 0) then {format [", %1 of them patrolling from where they stood", _patrolFromStart]} else {""};
    ["ALIVE_fnc_groupGarrison - %6: %1 %2 of %3 men across %4 buildings (%7 per building, limit %8)%9, %5 refused as already claimed by another group",
     _verb, _seatDemand - (count _units), _seatDemand, _claimed, _claimDenied, _group, _perBuilding, _limitNote, _patrolNote] call ALiVE_fnc_dump;
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
