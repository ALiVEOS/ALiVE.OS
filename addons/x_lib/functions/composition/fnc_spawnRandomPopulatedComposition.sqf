#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(spawnRandomPopulatedComposition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spawnRandomPopulatedComposition

Description:
Spawn a composition
Spawns a random populated composition

Parameters:
Position - Array
Type - String - Civilian, Military, Guerrilla
Category - String

    Civilian Categories - airports, checkpointsbarricades, construction, constructionSupplies, communications, fuel, general, heliports, industrial, marine, mining_oil, power, rail, settlements
    Guerrilla Categories - camps, checkpointsbarricades, constructionsupplies, commnunications, fieldhq, fort, fuel, hq, marine, medical, outposts, power, supports
    Military Categories - airports, camps, checkpointsbarricades, constructionsupplies, communications, crashsites, fieldhq, fort, fuel, heliports, hq, marine, medical, outposts, power, supports, supplies

Faction - String (OPTIONAL)
Size - String (Large, Medium, Small, ANY)
Infantry groups - Integer (OPTIONAL)
Mot Groups - Integer (OPTIONAL)
Mech Groups - Integer (OPTIONAL)
Armoured Groups - Integer (OPTIONAL)
SpecOps Groups - Integer (OPTIONAL)

Returns:

Examples:
(begin example)
// spawn a fortification composition of any size with 2 OPF_F groups
_result = [_position, "Military", "Fort", "OPF_F", "Small", 2] call ALIVE_fnc_spawnRandomPopulatedComposition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_position",
    "_type",
    "_category",
    "_faction",
    ["_size", []], // Large, Medium, Small
    ["_countInfantry", random 3],
    ["_countMotorized", 0],
    ["_countMechanized", 0],
    ["_countArmored", 0],
    ["_countSpecOps", 0]
];

// Spawn a composition
if (isNil "_category") then {
    _category = ["camps", "communications", "fieldhq", "fort", "fuel", "heliports", "hq", "medical", "outposts", "power", "supports", "supplies"];
};

private _compositions = [_type, _category, _size, _faction] call ALiVE_fnc_getCompositions;
private _composition = selectRandom _compositions;

// should probably exit if no composition is spawned
// TODO: return spawned composition (and maybe it's guard groups)
if (count _composition > 0) then {
    [_composition, _position, random 360, _faction] call ALIVE_fnc_spawnComposition;
};

// Assign groups
private _groups = [];

for "_i" from 0 to _countArmored -1 do {
    private _group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
    if (_group != "FALSE") then {
        _groups pushback _group;
    };
};

for "_i" from 0 to _countMechanized -1 do {
    private _group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
    if (_group != "FALSE") then {
        _groups pushback _group;
    }
};

if(_countMotorized > 0) then {
    private _motorizedGroups = [];

    for "_i" from 0 to _countMotorized -1 do {
        private _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
        if (_group != "FALSE") then {
            _motorizedGroups pushback _group;
        };
    };

    if(count _motorizedGroups == 0) then {
        for "_i" from 0 to _countMotorized -1 do {
            private _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
            if (_group != "FALSE") then {
                _motorizedGroups pushback _group;
            };
        };
    };

    _groups append _motorizedGroups;
};

private _infantryGroups = [];
for "_i" from 0 to _countInfantry -1 do {
    private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
    if (_group != "FALSE") then {
        _infantryGroups pushback _group;
    }
};

_groups append _infantryGroups;

for "_i" from 0 to _countSpecOps -1 do {
    private _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
    if (_group != "FALSE") then {
        _groups pushback _group;
    };
};

_groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;
_infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;

// Position and create groups
private _groupCount = count _groups;
private _totalCount = 0;

if(_groupCount > 0) then {

    if(count _infantryGroups > 0) then {
        private _guardGroup = selectRandom _infantryGroups;
        private _guards = [_guardGroup, _position, random(360), true, _faction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

        {
            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[100,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
            };
        } foreach _guards;
    };

    for "_i" from 0 to _groupCount -1 do {
        private _group = _groups select _i;
        _position = _position getPos [(random(200)), random(360)]; // should this be overwriting _position?

        if !(surfaceIsWater _position) then {
            private _units = [_group, _position, random(360), false, _faction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

            {
                if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                    [_x, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[100,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                };
            } foreach _units;
        };
    };
};