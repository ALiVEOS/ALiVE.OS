#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(spawnRandomPopulatedComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spawnRandomPopulatedComposition

Description:
Spawn a composition
Spawns a random populated composition

Parameters:
Config - group
Array - position
Scalar - direction

Returns:

Examples:
(begin example)
// spawn a composition from the objectives category with 2 OPF_F groups
_result = [_position, "objectives", "OPF_F", 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_category","_faction","_countInfantry","_countMotorized","_countMechanized","_countArmored","_countSpecOps",
"_compositions","_composition","_groups","_motorizedGroups","_infantryGroups","_groupCount","_totalCount","_guardGroup","_guards","_group"];

_position = _this select 0;
_category = _this select 1;
_faction = _this select 2;
_countInfantry = if(count _this > 3) then {_this select 3} else { random(3) };
_countMotorized = if(count _this > 4) then {_this select 4} else { 0 };
_countMechanized = if(count _this > 5) then {_this select 5} else { 0 };
_countArmored = if(count _this > 6) then {_this select 6} else { 0 };
_countSpecOps = if(count _this > 7) then {_this select 7} else { 0 };

// Spawn a composition

_compositions = [ALIVE_compositions,_category] call ALIVE_fnc_hashGet;
_composition = selectRandom _compositions;

_composition = [_composition] call ALIVE_fnc_findComposition;

if(count _composition > 0) then {
    [_composition, _position, random 360] call ALIVE_fnc_spawnComposition;
};

// Assign groups
_groups = [];

for "_i" from 0 to _countArmored -1 do {
    _group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
    if!(_group == "FALSE") then {
        _groups pushback _group;
    };
};

for "_i" from 0 to _countMechanized -1 do {
    _group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
    if!(_group == "FALSE") then {
        _groups pushback _group;
    }
};

if(_countMotorized > 0) then {

    _motorizedGroups = [];

    for "_i" from 0 to _countMotorized -1 do {
        _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
        if!(_group == "FALSE") then {
            _motorizedGroups pushback _group;
        };
    };

    if(count _motorizedGroups == 0) then {
        for "_i" from 0 to _countMotorized -1 do {
            _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
            if!(_group == "FALSE") then {
                _motorizedGroups pushback _group;
            };
        };
    };

    _groups = _groups + _motorizedGroups;
};

_infantryGroups = [];
for "_i" from 0 to _countInfantry -1 do {
    _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
    if!(_group == "FALSE") then {
        _infantryGroups pushback _group;
    }
};

_groups = _groups + _infantryGroups;

for "_i" from 0 to _countSpecOps -1 do {
    _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
    if!(_group == "FALSE") then {
        _groups pushback _group;
    };
};

_groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;
_infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;

// Position and create groups
_groupCount = count _groups;
_totalCount = 0;

if(_groupCount > 0) then {

    if(count _infantryGroups > 0) then {
        _guardGroup = selectRandom _infantryGroups;
        _guards = [_guardGroup, _position, random(360), true, _faction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

        {
            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[200,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
            };
        } foreach _guards;
    };

    for "_i" from 0 to _groupCount -1 do {

        _group = _groups select _i;

        _position = _position getPos [(random(200)), random(360)];

        if!(surfaceIsWater _position) then {

            [_group, _position, random(360), false, _faction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

        };
    };
};