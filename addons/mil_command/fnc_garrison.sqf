#include "\x\alive\addons\mil_command\script_component.hpp"
SCRIPT(garrison);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrison

Description:
Garrison command for active units, run on spawn of profiles for guarding of objectives via placement modules

Parameters:
Array - Virtual Profile
Number/Array - Radius or [_radius, only Profiles]

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",200]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead, Jman
---------------------------------------------------------------------------- */

private ["_type","_waypoints","_unit","_profile","_active","_args","_pos","_radius","_onlyProfiles","_assignments","_group","_profileType","_profileCount","_guardPatrolPercentage","_patrolBehaviour","_patrolSpeed","_cbaRadius","_preferredGarrison","_fillShortfall","_hadModuleSetting","_preferredIndicesOnly","_searchCentre","_objectiveSize","_searchRadius"];

_profile = _this param [0, ["",[],[],nil], [[]]];
_args = _this param [1, 200, [-1,[]]];
// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
 ["ALIVE_fnc_garrison - _args: %1",_args] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------
_radius = _args;
_onlyProfiles = true;
_profileType = "";
_profileCount = 0;
_guardPatrolPercentage = 50;
_patrolBehaviour = "SAFE";
_patrolSpeed = "LIMITED";
_preferredGarrison = "";
_fillShortfall = true;
_hadModuleSetting = false;
_preferredIndicesOnly = false;
// SPE garrison: radius to sweep for CBA AI Building Positions (the objective's Size). (#945)
_cbaRadius = 300;
// The objective this garrison was sent to hold, when the caller has one. Slot [2] began as
// a position slot every non-SPE caller filled with [0,0,0]; it carries the objective centre
// now, and slot [10] its size. A caller without an objective leaves both alone and searches
// from where the group stands, exactly as before.
_searchCentre = [];
_objectiveSize = 0;


if (_args isEqualType []) then {
    _radius = _args param [0, 200, [-1]];
    _onlyProfiles = (_args param [1, "false", [""]]) == "true";
    // [2] carries either the SPE objective Size as a Number, or the centre of the objective
    // this garrison belongs to. [0,0,0] and a missing slot both mean "no objective", which is
    // what the roadblock, task camp, airbase, HQ and commander garrisons send.
    private _slot2 = _args param [2, [0,0,0]];
    if (_slot2 isEqualType 0) then { _cbaRadius = _slot2 };
    if (_slot2 isEqualType [] && {count _slot2 >= 2} && {(_slot2 select 0) isEqualType 0}
        && {!(((_slot2 select 0) == 0) && {(_slot2 select 1) == 0})}) then {
        // Cluster centres are stored as two elements. Normalised here so everything
        // downstream gets the same shape whatever the caller had to hand.
        _searchCentre = [_slot2 select 0, _slot2 select 1, _slot2 param [2, 0]];
    };
    _profileType = _args param [3, ""];
    _profileCount = _args param [4, 0];
    _guardPatrolPercentage = _args param [5, 50, [0]];
    // Patrol disposition for the garrison building-patrol leg. Defaults
    // preserve every existing caller (incl. roadblocks) that pass a
    // 6-element args array.
    _patrolBehaviour = _args param [6, "SAFE", [""]];
    _patrolSpeed = _args param [7, "LIMITED", [""]];
    // The preferred garrison buildings setting from the module that issued this
    // command, still in its canonical Class=idx,idx;... string form. A module left
    // blank sends an empty string and means it, so what marks a caller as having had
    // a module to ask is whether the slot is there at all, not what is in it.
    _preferredGarrison = _args param [8, "", [""]];
    _hadModuleSetting = count _args > 8;
    // Whether this garrison may look past the curated props when they cannot seat the
    // group. On unless a caller says otherwise. The commander re-garrisoning a captured
    // objective, the insurgency guards and the airbase guards all arrive here with the
    // short array their FSMs have always sent, and while this was off by default a
    // platoon of twenty three men sent at fourteen curated seats filled the bunkers and
    // handed the other sixteen to ambient movement.
    _fillShortfall = (_args param [9, true, [false]]);
    // The objective's own size, so the search can cover it rather than a fixed radius from
    // wherever the group was scattered to within it.
    _objectiveSize = _args param [10, 0, [0]];
    // DEBUG -------------------------------------------------------------------------------------
    if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
     ["ALIVE_fnc_garrison - _profileType: %1, _profileCount: %2, _guardPatrolPercentage: %3", _profileType, _profileCount, _guardPatrolPercentage] call ALiVE_fnc_dump;
    };
    // DEBUG -------------------------------------------------------------------------------------
};

// A caller with no placement module behind it is given the mission's list. The
// commander ordering a garrison from tacom, the insurgency guards and the airbase
// guards reach here with the short array their FSM has always sent, and an FSM has
// no module logic to read the setting off. Eden writes the attribute onto each
// placement module at load, so the modules are read directly rather than made to
// announce themselves, which also picks up any module that gains the attribute
// later.
//
// A module that was left blank is NOT given anybody else's list. Its garrisons
// would otherwise sweep for another module's classes out to the full guard radius
// and seat men in them ahead of the objective's own props, which is the opposite
// of what leaving the field empty asks for.
if (!_hadModuleSetting) then {
    // Gathered once and kept. The answer cannot change after mission start, and
    // without this every garrison in the mission would sweep the entity list again.
    if (isNil "ALiVE_preferredGarrisonPositions") then {
        ALiVE_preferredGarrisonPositions = (((entities "Module_F") apply {
            _x getVariable ["preferredGarrisonPositions", ""]
        }) select {
            // Only a segment carrying an "=" can name a class, so a field holding
            // nothing but a stray space or line break is not pooled as one.
            _x isEqualType "" && {(_x find "=") > -1}
        }) joinString ";";
    };
    _preferredGarrison = ALiVE_preferredGarrisonPositions;
    if !(_preferredGarrison isEqualType "") then { _preferredGarrison = "" };
    // Taken, not chosen: these classes supply the positions worth standing in, but must
    // not become buildings this garrison walks to ahead of the ones it is already at.
    _preferredIndicesOnly = true;
};


if (isnil "_profile") exitWith {};
_id = [_profile,"profileID","error"] call ALiVE_fnc_HashGet;
_pos = [_profile,"position"] call ALiVE_fnc_HashGet;
_type = [_profile,"type",""] call ALiVE_fnc_HashGet;
_waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
_assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;

// How far to search. The objective wins where it is larger, so a group thrown to the rim
// of a big objective still reaches the buildings in the middle of it; the module's guard
// radius is the floor, so a mission that raised it keeps that reach on a small objective.
// Capped because the sweep cost grows with the area and civilian clusters run to 1440 m:
// 700 is the ceiling fnc_strategic uses when it merges clusters, borrowed here as a cost
// ceiling rather than because cluster sizes are bounded by it. Beyond the cap the rim is
// covered by the house fallback, which is drawn around the men rather than the objective.
_searchRadius = _radius max ((_objectiveSize max 0) min 700);

if (isnil "_pos") exitwith {
    // ["MIL COMMAND Garrison - Detected wrong input for profile %1! Exiting...",_id] call ALiVE_fnc_dump;
};

// No objective given, so the search is centred where the group is, as it always was.
if (_searchCentre isEqualTo []) then { _searchCentre = _pos };

if (count _waypoints > 0) then {
    // ["MIL COMMAND Garrison - Detected existing waypoints for profile %1! Deleting...",_id] call ALiVE_fnc_dump;
	[_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
};

// Garrison Building Patrol set to None means the guard should hold its post, so it is not
// given anywhere to wander either. Until now these waypoints were laid whatever the module
// said, and a garrison told not to patrol still walked the objective, both while virtual and
// once spawned. Callers that do not pass the setting keep the default of 50 and are
// unaffected, and the roadblock and reserve paths pass 1 deliberately.
if (_guardPatrolPercentage > 0) then {
    // A third of the module's own guard radius, deliberately not of the search radius. Tied
    // to the search it would scale with the objective, and a guard told to hold a 700 m
    // objective would wander 230 m from his post.
    [_profile,_radius/3] call ALiVE_fnc_ambientMovement;
};

waituntil {
    sleep 0.5;
    [_profile,"active"] call ALiVE_fnc_HashGet;
};
sleep 0.3;

if (_type == "entity" && {count (_assignments select 1) == 0}) then {

    _group = _profile select 2 select 13;

    // Where the group actually is, read now rather than from the position the command was
    // issued with. The profile may have been virtual for a long time and the ambient wander
    // above has had its say, so _pos is where it was sent, not where it stands. Candidates
    // are handed out nearest to this.
    private _groupPos = _pos;
    if (!isNull _group && {!isNull (leader _group)}) then { _groupPos = getPosATL (leader _group) };

    if (_profileType == "SPE") then {
    	// DEBUG -------------------------------------------------------------------------------------
    	if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
       ["ALIVE_fnc_garrison - calling ALIVE_fnc_groupGarrisonSPE - _profileType: %1",_profileType] call ALiVE_fnc_dump;
      };
      // DEBUG -------------------------------------------------------------------------------------
     [_group, _pos, _radius, true, _onlyProfiles, _cbaRadius] call ALIVE_fnc_groupGarrisonSPE;
    } else {
    	// DEBUG -------------------------------------------------------------------------------------
    	if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
       ["ALIVE_fnc_garrison - calling ALIVE_fnc_groupGarrison - searching %4 m around %6 (objective size %7, guard radius %8), group %2 is %9 m from it, profileID: %3, profileType: %1, guardPatrolPercentage: %5", _profileType, _group, _id, round _searchRadius, _guardPatrolPercentage, _searchCentre, round _objectiveSize, round _radius, round (_groupPos distance2D _searchCentre)] call ALiVE_fnc_dump;
      };
      // DEBUG -------------------------------------------------------------------------------------
     [_group, _searchCentre, _searchRadius, true, _onlyProfiles, _profileCount, _id, _guardPatrolPercentage, _patrolBehaviour, _patrolSpeed, _preferredGarrison, _fillShortfall, _preferredIndicesOnly, _groupPos, _radius] call ALIVE_fnc_groupGarrison;
    };

};
