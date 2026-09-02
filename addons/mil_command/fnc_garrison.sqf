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

private ["_type","_waypoints","_unit","_profile","_active","_args","_pos","_radius","_onlyProfiles","_assignments","_group","_profileType","_profileCount","_guardPatrolPercentage","_patrolBehaviour","_patrolSpeed","_cbaRadius","_preferredGarrison","_fillShortfall","_hadModuleSetting","_preferredIndicesOnly"];

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


if (_args isEqualType []) then {
    _radius = _args param [0, 200, [-1]];
    _onlyProfiles = (_args param [1, "false", [""]]) == "true";
    // [2] is a legacy position slot that non-SPE callers fill with [0,0,0]; the SPE placer
    // overloads it with the objective Size. Take a Number if present, else keep the default 300.
    _cbaRadius = _args param [2, 300];
    if !(_cbaRadius isEqualType 0) then { _cbaRadius = 300; };
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

if (isnil "_pos") exitwith {
    // ["MIL COMMAND Garrison - Detected wrong input for profile %1! Exiting...",_id] call ALiVE_fnc_dump;
};

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
    [_profile,_radius/3] call ALiVE_fnc_ambientMovement;
};

waituntil {
    sleep 0.5;
    [_profile,"active"] call ALiVE_fnc_HashGet;
};
sleep 0.3;

if (_type == "entity" && {count (_assignments select 1) == 0}) then {

    _group = _profile select 2 select 13;

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
       ["ALIVE_fnc_garrison - calling ALIVE_fnc_groupGarrison - _radius: %4,  _profileID: %3, _profileType: %1, _group: %2, _guardPatrolPercentage: %5", _profileType, _group, _id, _radius, _guardPatrolPercentage] call ALiVE_fnc_dump;
      };
      // DEBUG -------------------------------------------------------------------------------------
     [_group, _pos, _radius, true, _onlyProfiles, _profileCount, _id, _guardPatrolPercentage, _patrolBehaviour, _patrolSpeed, _preferredGarrison, _fillShortfall, _preferredIndicesOnly] call ALIVE_fnc_groupGarrison;
    };

};
