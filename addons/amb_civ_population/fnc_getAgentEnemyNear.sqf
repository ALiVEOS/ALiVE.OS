#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(getAgentEnemyNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getAgentEnemyNear

Description:
Find an agent enemy nearby

Parameters:
Array - cluster hash
Array - position
Scalar - distance

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [getPos _agent, 300] call ALIVE_fnc_getAgentEnemyNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_cluster","_position","_distance"];

private _result = [];

private _clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;

private _hostilitySettingsEAST = [_clusterHostility, "EAST"] call ALIVE_fnc_hashGet;
private _hostilitySettingsWEST = [_clusterHostility, "WEST"] call ALIVE_fnc_hashGet;
private _hostilitySettingsINDEP = [_clusterHostility, "GUER"] call ALIVE_fnc_hashGet;
//_hostilitySettingsGUER = [_clusterHostility, "GUER"] call ALIVE_fnc_hashGet;

private _hostilitySides = ["EAST","WEST","GUER"];
private _hostilityNumbers = [_hostilitySettingsEAST, _hostilitySettingsWEST, _hostilitySettingsINDEP];

private _nearUnits = [] call ALIVE_fnc_hashCreate;
[_nearUnits, "EAST", []] call ALIVE_fnc_hashSet;
[_nearUnits, "WEST", []] call ALIVE_fnc_hashSet;
[_nearUnits, "GUER", []] call ALIVE_fnc_hashSet;

private _nearEAST = [_nearUnits, "EAST"] call ALIVE_fnc_hashGet;
private _nearWEST = [_nearUnits, "WEST"] call ALIVE_fnc_hashGet;
private _nearINDEP = [_nearUnits, "GUER"] call ALIVE_fnc_hashGet;

{
    if(_position distance position _x < _distance) then {
        if(alive _x) then {
            switch(side (group _x)) do {
                case west:{
                    _nearWEST pushback _x;
                };
                case east:{
                    _nearEAST pushback _x;
                };
                case resistance:{
                    _nearINDEP pushback _x;
                };
            };
        };
    };
} forEach (_position nearEntities ["CAManBase", _distance]);

{
    if(_position distance position _x < _distance) then {
        if(alive _x) then {
            switch(side (group _x)) do {
                case west:{
                    _nearWEST pushback _x;
                };
                case east:{
                    _nearEAST pushback _x;
                };
                case resistance:{
                    _nearINDEP pushback _x;
                };
            };
        };
    };
} forEach allPlayers;

_nearEAST = [_nearUnits, "EAST"] call ALIVE_fnc_hashGet;
_nearWEST = [_nearUnits, "WEST"] call ALIVE_fnc_hashGet;
_nearINDEP = [_nearUnits, "GUER"] call ALIVE_fnc_hashGet;

/*
["HOST EAST %1",_hostilitySettingsEAST] call ALIVE_fnc_dump;
["HOST WEST %1",_hostilitySettingsWEST] call ALIVE_fnc_dump;
["HOST INDEP %1",_hostilitySettingsINDEP] call ALIVE_fnc_dump;
["NEAR EAST %1",_nearEAST] call ALIVE_fnc_dump;
["NEAR WEST %1",_nearWEST] call ALIVE_fnc_dump;
["NEAR INDEP %1",_nearINDEP] call ALIVE_fnc_dump;
*/

private _highest = 0;
private _highestIndex = 0;
{
    if(_x > _highest) then {
        _highest = _x;
        _highestIndex = _forEachIndex;
    };
} foreach _hostilityNumbers;

private _mostHostileSide = _hostilitySides select _highestIndex;

/*
["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
["most hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
*/

private ["_units","_unit"];

if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
    if(_highest > 0) then {
        _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
        _unit = selectRandom _units;
        _result = [_unit];
    }
}else{
    _hostilityNumbers set [_highestIndex, -1];

    _highest = 0;
    _highestIndex = 0;
    {
        if(_x > _highest) then {
            _highest = _x;
            _highestIndex = _forEachIndex;
        };
    } foreach _hostilityNumbers;

    _mostHostileSide = _hostilitySides select _highestIndex;

    /*
    ["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
    ["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
    ["next most hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
    */

    if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
        if(_highest > 0) then {
            _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
            _unit = selectRandom _units;
            _result = [_unit];
        }
    }else{
        _hostilityNumbers set [_highestIndex, -1];

        _highest = 0;
        _highestIndex = 0;
        {
            if(_x > _highest) then {
                _highest = _x;
                _highestIndex = _forEachIndex;
            };
        } foreach _hostilityNumbers;

        _mostHostileSide = _hostilitySides select _highestIndex;

        /*
        ["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
        ["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
        ["least hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
        */

        if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
            if(_highest > 0) then {
                _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
                _unit = selectRandom _units;
                _result = [_unit];
            }
        };
    };

};

_result
